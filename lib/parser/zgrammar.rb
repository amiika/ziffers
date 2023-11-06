
require "treetop"
require_relative "../defaults.rb"
require_relative "./scala.rb"

'''
# For testing and debugging
load "~/ziffers/lib/defaults.rb"
'''

module Ziffers
  module Grammar
    include SonicPi
    include SonicPi::Lang::WesternTheory
    include Ziffers::Defaults

    Treetop.load(File.expand_path(File.join(File.dirname(__FILE__), 'ziffers.treetop')))
    Treetop.load(File.expand_path(File.join(File.dirname(__FILE__), 'generative.treetop')))
    Treetop.load(File.expand_path(File.join(File.dirname(__FILE__), 'parameters.treetop')))
    Treetop.load(File.expand_path(File.join(File.dirname(__FILE__), 'repeats.treetop')))
    Treetop.load(File.expand_path(File.join(File.dirname(__FILE__), 'scala.treetop')))

    @@zparser = ZiffersParser.new
    @@rparser = GenerativeSyntaxParser.new
    @@lparser = ParametersParser.new
    @@repeatparser = RepeatsParser.new
    @@scalaparser = ScalaParser.new
    @@thread_parsers = {} # Build separate parser for each thread

    def resolve_subsets(subs,divSleep)
      new_list = subs.each_with_object([]) do |z,n|
        if z[:subset]
          n.push(*resolve_subsets(z[:subset],divSleep/z[:subset].length))
        else
          z[:duration] = divSleep
          z[:beats] = z[:duration]*4
          n.push(z)
        end
      end
      new_list
    end

    def resolve_cycle(item, index, repeats=0)
      if item.is_a?(Hash) && item[:cycle]
        index = [index] if !index.is_a?(Array) # Turn first level index to array to form index for all levels
        index_sym = index.join.to_sym
        cycle_opts = repeats<2 ? (:cycle_counters) : (:local_counters)
        if !Thread.current[:tshared][cycle_opts]
          Thread.current[:tshared][cycle_opts] = {}
          Thread.current[:tshared][cycle_opts][index_sym] = 0
        elsif !Thread.current[:tshared][cycle_opts][index_sym]
          Thread.current[:tshared][cycle_opts][index_sym] = 0
        else
          Thread.current[:tshared][cycle_opts][index_sym] += 1
        end
        loop_i =  Thread.current[:tshared][cycle_opts][index_sym]
        itm_index = loop_i%item[:cycle].length
        item = item[:cycle][itm_index]
        if item.is_a?(Array)
          item = item.map do |h|
            (h.is_a?(Hash) && h[:cycle]) ? resolve_cycle(h, index.push(itm_index), repeats) : h
          end
          item = ZiffArray.new(item.flatten)
        end
      elsif item.is_a?(Hash) && item[:subset]
        item = resolve_subsets(item[:subset], item[:subduration]/item[:subset].length)
      else
        item = item.is_a?(Array) ? ZiffArray.new(item.flatten) : item
      end
      item
    end

    def sonic_random(min,max)
      return min if min == max
      range = (min - max).abs
      r = SonicPi::Core::SPRand.rand_i!(range.to_i + 1)
      smallest = [min, max].min
      (r + smallest)
    end

    def sonic_random_float(min,max,ro=nil)
      range = (min - max).abs
      r = SonicPi::Core::SPRand.rand!(range)
      smallest = [min, max].min
      v = (r + smallest)
      v = v.round(ro) if ro
      v
    end

    @@modes = {
      :a=>:aeolian,
      :b=>:locrian,
      :c=>:ionian,
      :d=>:dorian,
      :e=>:phrygian,
      :f=>:lydian,
      :g=>:mixolydian,
    }
    @@modes.default = :ionian

    def mode_to_scale(letter)
      @@modes[letter.to_sym]
    end

    def sonic_range(s,e,step=nil,mult=nil,reflect=false)
      ms = (s>e) ? e : s # 1..7
      me = (e<s) ? s : e # 7..1

      if (mult and mult=="*")
        if s>e
          if e>0
            nArr = s.step(by: step).take(e.abs)
          else
            if e<0
              nArr = s.step(by: -step).take(e.abs)
            else
              nArr = ms.step(by: step).take(me.abs).reverse
            end
          end
        else
          nArr = s.step(by: e<0 ? -step : step).take(e.abs)
        end
      elsif (mult and mult=="**")
        raise "Invalid geometric sequence" if ms<0 or me<=0
        nArr = (ms...me).map { |v| a = ((ms==0 ? ms+1 : ms) * step.abs ** v).to_i ; step<0 ? -a : a}
        nArr = nArr.reverse if e<s
      else
        nArr = step ? ms.step(by: step, to: me).to_a : ms.is_a?(Float) ? ms.step(to: me, by: 0.1).to_a : ms.step(to: me).to_a
        nArr = nArr.reverse if e<s
      end

      nArr = nArr + nArr.drop(1).reverse.drop(1) if reflect
      nArr
    end

    def deep_clone(h)
      Marshal.load(Marshal.dump(h))
    end

    # Parse shit using treeparse
    def parse_ziffers(text, opts, shared)
      # TODO: Find a better way to inject parameters for the parser ... or at least combine & rename
      Thread.current[:tshared] = shared
      Thread.current[:counter] = 0
      Thread.current[:topts] = opts
      Thread.current[:tarp] = nil
      opts = opts.filter {|k,v| !v.is_a?(Proc) }
      Thread.current[:topts_orig] = Marshal.load(Marshal.dump(opts))
      Thread.current[:default_durs] = @@default_durs
      Thread.current[:topts][:measure] = 0

      loop_name = shared[:loop_name]
      if loop_name
        @@thread_parsers[loop_name] = {} if !@@thread_parsers[loop_name]
        @@thread_parsers[loop_name][:parser] = ZiffersParser.new if !@@thread_parsers[loop_name][:parser]
        zparser = @@thread_parsers[loop_name][:parser]
        result = zparser.parse(text)
      else
        zparser = @@zparser
        result = zparser.parse(text)
      end

      # Note to self: Do not call result.value more than once to avoid endless debugging.
      if !result
        zlog "PARSE CRASH DEBUG: "
        zlog zparser.failure_reason
        zlog zparser.failure_line
        zlog zparser.failure_column
        zlog text
        zlog opts
        zlog shared
        raise "Invalid syntax after: "+parse_failure(zparser.failure_reason)
      end

      ziffers = ZiffArray.new(result.value)

      # Calculate random durations relatively for each measure
      if Thread.current[:topts].has_key?(:relative_duration)
        measures = ziffers.measures

        measures.each do |m|
          used = m.inject({total_duration: 0, count: 0}) do |sum,h|
            if h[:relative_duration]
              sum[:count] = sum[:count]+1
            else
              sum[:total_duration] = sum[:total_duration]+h[:duration]
            end
            sum
          end
          duration_left = (Thread.current[:tshared][:measure_length] || 1.0)-used[:total_duration]
          m.each do |h|
            if h[:relative_duration]
              if h[:relative_duration_value] and used[:count]>1
                h[:duration] = ([h[:relative_duration_value],1.0].min * duration_left).round(3)
                duration_left = duration_left-h[:duration]
                used[:count] = used[:count]-1
              elsif used[:count]>1
                h[:duration] = (sonic_random_float(0.01,duration_left,2) * duration_left).round(3)
                duration_left = duration_left-h[:duration]
                used[:count] = used[:count]-1
              else
                h[:duration] = duration_left.round(3)
              end
              h[:beats] = h[:duration]*4
            end
          end
        end

        ziffers = ZiffArray.new(measures.flatten)
      end
      if !shared[:loop_name] or shared[:is_enum]
        apply_array_transformations ziffers, opts, shared
      else
        ziffers
      end
    end

    def parse_generative(text, opts={}, shared={}, return_shared_opts=false)
      shared = shared.filter {|k,v| !v.is_a?(Proc) }
      opts = opts.filter {|k,v| !v.is_a?(Proc) }
      Thread.current[:default_durs] = @@default_durs
      Thread.current[:tshared] = deep_clone(shared.except(:rules,:run,:use,:multi,:rhythm))
      Thread.current[:tchordduration] = opts[:chord_duration]
      Thread.current[:topts] = deep_clone(opts)

      loop_name = shared[:loop_name]
      if loop_name
        @@thread_parsers[loop_name] = {} if !@@thread_parsers[loop_name]
        if shared[:substitution]
          @@thread_parsers[loop_name][:substitution_parser] = GenerativeSyntaxParser.new if !@@thread_parsers[loop_name][:substitution_parser]
          rparser = @@thread_parsers[loop_name][:substitution_parser]
        elsif shared[:string_rewrite_loop]
          @@thread_parsers[loop_name][:rewrite_parser] = GenerativeSyntaxParser.new if !@@thread_parsers[loop_name][:rewrite_parser]
          rparser = @@thread_parsers[loop_name][:rewrite_parser]
        else
          @@thread_parsers[loop_name][:gen_parser] = GenerativeSyntaxParser.new if !@@thread_parsers[loop_name][:gen_parser]
          rparser = @@thread_parsers[loop_name][:gen_parser]
        end
        result = rparser.parse(text)
      else
        rparser = @@rparser
        result = rparser.parse(text)
      end

      if !result
        zlog "GENERATIVE CRASH DEBUG: "
        zlog rparser.failure_reason
        zlog rparser.failure_line
        zlog rparser.failure_column
        zlog "INPUT: "
        zlog text
        zlog "OPTS: "
        zlog opts
        zlog "DEFAULTS: "
        zlog shared
        Thread.current[:tshared][:error] = "Invalid syntax after: "+parse_failure(rparser.failure_reason)
      end
      return_shared_opts ? [(result ? result.value : nil),Thread.current[:tshared]] : result.value
    end

    def parse_failure(text)
      return "'"+text.match(/after(\S*) (.*)/)[2]+"'"
    end

    def parse_params(text,opts={})
      return nil if !text
      Thread.current[:ziffers_param_opts] = opts

      loop_name = opts[:loop_name]
      if loop_name
        @@thread_parsers[loop_name] = {} if !@@thread_parsers[loop_name]
        @@thread_parsers[loop_name][:param_parser] = ParametersParser.new if !@@thread_parsers[loop_name][:param_parser]
        lparser = @@thread_parsers[loop_name][:param_parser]
        result = lparser.parse(text)
      else
        lparser =  @@lparser
        result = lparser.parse(text)
      end

      if !result
        zlog "PARAMS CRASH DEBUG: "
        zlog lparser.failure_reason
        zlog lparser.failure_line
        zlog lparser.failure_column
        zlog text
        raise "Invalid syntax after: "+parse_failure(lparser.failure_reason)
      end

      result.value
    end

    # Currently used only in multi line parsing
    def unroll_repeats(text)
      return nil if !text

      repeatparser = @@repeatparser
      result = repeatparser.parse(text)

      if !result
        zlog "REPEATS CRASH DEBUG: "
        zlog repeatparser.failure_reason
        zlog repeatparser.failure_line
        zlog repeatparser.failure_column
        zlog text
        raise "Invalid syntax after: "+parse_failure(repeatparser.failure_reason)
      end
      result.value
    end

    def parse_scala(text)
      return nil if !text

      scalaparser = @@scalaparser
      result = scalaparser.parse(text)

      if !result
        zlog "REPEATS CRASH DEBUG: "
        zlog scalaparser.failure_reason
        zlog scalaparser.failure_line
        zlog scalaparser.failure_column
        zlog text
        raise "Invalid syntax after: "+parse_failure(scalaparser.failure_reason)
      end
      result.value
    end

  end
end
