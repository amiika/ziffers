
require_relative "../defaults.rb"

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

    @@zparser = ZiffersParser.new
    @@rparser = GenerativeSyntaxParser.new
    @@lparser = ParametersParser.new
    @@repeatparser = RepeatsParser.new
    @@thread_parsers = {} # Build separate parser for each thread

    def resolve_subsets(subs,divSleep)
      new_list = subs.each_with_object([]) do |z,n|
        if z[:subset]
          n.push(*resolve_subsets(z[:subset],divSleep/z[:subset].length))
        else
          z[:sleep] = divSleep
          n.push(z)
        end
      end
      new_list
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

    def bin_euclid(pulse,step)
      ratio = 1.0*step/pulse
      rhythm = Array.new(step,0);
      index = 0
      pulse.times do
        rhythm[index.to_i] = 1
        index += ratio
      end
      # In Sonic Pi's spread algorithm booleans seem to rotated if there are consecutive true values
      rhythm = (rhythm[0]==1 and rhythm[1]==1) ? rhythm.rotate(-2) : rhythm
      return rhythm
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
        raise "Invalid syntax after: "+parse_failure(@@zparser.failure_reason)
      end

      ziffers = ZiffArray.new(result.value)

      # Calculate random durations relatively for each measure
      if Thread.current[:topts].has_key?(:relative_duration)
        measures = ziffers.measures

        measures.each do |m|
          used = m.inject({duration: 0, count: 0}) do |sum,h|
            if h[:relative_duration]
              sum[:count] = sum[:count]+1
            else
              sum[:duration] = sum[:duration]+h[:sleep]
            end
            sum
          end
          duration_left = (Thread.current[:tshared][:measure_length] || 1.0)-used[:duration]
          m.each do |h|
            if h[:relative_duration]
              if h[:relative_duration_value] and used[:count]>1
                h[:sleep] = ([h[:relative_duration_value],1.0].min * duration_left).round(3)
                duration_left = duration_left-h[:sleep]
                used[:count] = used[:count]-1
              elsif used[:count]>1
                h[:sleep] = (sonic_random_float(0.01,duration_left,2) * duration_left).round(3)
                duration_left = duration_left-h[:sleep]
                used[:count] = used[:count]-1
              else
                h[:sleep] = duration_left.round(3)
              end
            end
          end
        end

        ziffers = ZiffArray.new(measures.flatten)
      end

      apply_array_transformations ziffers, opts, shared
    end

    def parse_generative(text, opts={}, shared={})
      shared = shared.filter {|k,v| !v.is_a?(Proc) }
      opts = opts.filter {|k,v| !v.is_a?(Proc) }
      Thread.current[:default_durs] = @@default_durs
      Thread.current[:tshared] = deep_clone(shared.except(:rules,:use,:multi))
      Thread.current[:tchordsleep] = opts[:chord_sleep]
      Thread.current[:topts] = deep_clone(opts)

      loop_name = shared[:loop_name]
      if loop_name
        @@thread_parsers[loop_name] = {} if !@@thread_parsers[loop_name]
        @@thread_parsers[loop_name][:gen_parser] = GenerativeSyntaxParser.new if !@@thread_parsers[loop_name][:gen_parser]
        rparser = @@thread_parsers[loop_name][:gen_parser]
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
        zlog text
        zlog opts
        zlog shared
        raise "Invalid syntax after: "+parse_failure(@@zparser.failure_reason)
      end
      result.value
    end

    def parse_failure(text)
      return "'"+text.match(/after(\S*) (.*)/)[2]+"'"
    end

    def parse_params(text,opts={})
      return nil if !text
      Thread.current[:ziffers_param_opts] = opts

      lparser =  @@lparser
      result = lparser.parse(text)

      if !result
        zlog "PARAMS CRASH DEBUG: "
        puts lparser.failure_reason
        puts lparser.failure_line
        puts lparser.failure_column
        zlog text
      end
      raise "Invalid syntax after: "+parse_failure(@@zparser.failure_reason) if !result
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
      end
      raise "Invalid syntax after: "+parse_failure(@@zparser.failure_reason) if !result
      result.value
    end

  end
end
