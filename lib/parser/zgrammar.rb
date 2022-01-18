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
    Treetop.load(File.expand_path(File.join(File.dirname(__FILE__), 'loops.treetop')))

    @@zparser = ZiffersParser.new
    @@rparser = GenerativeSyntaxParser.new
    @@lparser = LoopsParser.new

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

    def sonic_random_float(min,max)
      range = (min - max).abs
      r = SonicPi::Core::SPRand.rand!(range)
      smallest = [min, max].min
      (r + smallest)
    end

    def sonic_range(s,e,step=nil,mult=nil,reflect=false)
      ms = s>e ? e : s # 1..7
      me = e>s ? e : s # 7..1
      if step and mult and mult=="*"
        ms = ms*step
        me = me*step
      end
      nArr = (step ? (ms..me).step(step).to_a : (ms..me).to_a)
      nArr = nArr.reverse if s>e
      nArr = nArr + nArr.drop(1).reverse.drop(1) if reflect
      nArr
    end

    # Parse shit using treeparse
    def parse_ziffers(text, opts, shared, durs)
      # TODO: Find a better way to inject parameters for the parser
      Thread.current[:tchordsleep] = opts[:chord_sleep]
      Thread.current[:tshared] = shared
      Thread.current[:counter] = 0
      Thread.current[:topts] = opts
      Thread.current[:topts_orig] = Marshal.load(Marshal.dump(opts))
      Thread.current[:tarp] = nil
      Thread.current[:default_durs] = durs

      result = @@zparser.parse(text)

      if !result
        puts @@zparser.failure_reason
        puts @@zparser.failure_line
        puts @@zparser.failure_column
      end
      # Note to self: Do not call result.value more than once to avoid endless debugging.
      ziffers = ZiffArray.new(result.value)
      apply_array_transformations ziffers, opts, shared
    end

    def parse_generative(text, parse_chords=true)
      result = @@rparser.parse(text)
      # TODO: Find a better way to inject parameters for the parser
      Thread.current[:parse_chords] = parse_chords

      if !result
        puts @@rparser.failure_reason
        puts @@rparser.failure_line
        puts @@rparser.failure_column
      end

      result.value
    end

    def parse_loops(text, opts)
      lines = text.lines.filter {|v| !v.strip.empty? }
      Thread.current[:topts] = opts
      params = lines.map{ |l|
        l = l.chomp
        if(l.rstrip.end_with?("\\"))
          l = l.rstrip.delete_suffix("\\")
          multi_line = true
        else
          multi_line = false
        end
        if l.include?("//")
          [l]
        else
          v = l.split("/")
          v[1] = @@lparser.parse(v[1]).value if v[1] and v[1]!=""
          v[1] = v[1] ? v[1].merge({multi_line: true}) : {multi_line: true} if multi_line
          v
        end
      }
      params
    end

  end
end
