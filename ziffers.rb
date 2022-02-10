
require_relative "./lib/enumerables.rb"
require_relative "./lib/monkeypatches.rb"
require_relative "./lib/parser/zgrammar.rb"
require_relative "./lib/ziffarray.rb"
require_relative "./lib/ziffhash.rb"
require_relative "./lib/common.rb"
require_relative "./lib/generators.rb"
require_relative "./lib/defaults.rb"
require_relative "./lib/pc_sets.rb"

'''
# For testing and debugging
load "~/ziffers/lib/enumerables.rb"
load "~/ziffers/lib/monkeypatches.rb"
load "~/ziffers/lib/parser/zgrammar.rb"
load "~/ziffers/lib/ziffarray.rb"
load "~/ziffers/lib/ziffhash.rb"
load "~/ziffers/lib/common.rb"
load "~/ziffers/lib/generators.rb"
load "~/ziffers/lib/defaults.rb"
load "~/ziffers/lib/pc_sets.rb"
'''

print "Ziffers 2.0 alpha"

module Ziffers

    include Ziffers::Enumerables
    include Ziffers::Grammar
    include Ziffers::Defaults
    include Ziffers::Common
    include Ziffers::Generators

    @@default_opts = {
      :key => :c,
      :scale => :major,
      :release => 1.0,
      :sleep => 1.0
    }

    @@slice_opts_keys = [:scale, :key, :synth, :amp, :sleep, :port, :channel, :note, :notes, :amp, :pan, :attack, :decay, :sustain, :release, :pc, :pcs, :rate, :pitch, :run_each, :methods]

    @@debug = false
    @@set_keys = [:pc]

    $easing = {
      linear: -> (t, b, c, d) { c * t / d + b },
      in_quad: -> (t, b, c, d) { c * (t/=d)*t + b },
      out_quad: -> (t, b, c, d) { -c * (t/=d)*(t-2) + b },
      quad: -> (t, b, c, d) { ((t/=d/2) < 1) ? c/2*t*t + b : -c/2 * ((t-=1)*(t-2) - 1) + b },
      in_cubic: -> (t, b, c, d) { c * (t/=d)*t*t + b },
      out_cubic: -> (t, b, c, d) { c * ((t=t/d-1)*t*t + 1) + b },
      cubic: -> (t, b, c, d) { ((t/=d/2) < 1) ? c/2*t*t*t + b : c/2*((t-=2)*t*t + 2) + b },
      in_quart: -> (t, b, c, d) { c * (t/=d)*t*t*t + b },
      out_quart: -> (t, b, c, d) { -c * ((t=t/d-1)*t*t*t - 1) + b },
      quart: -> (t, b, c, d) { ((t/=d/2) < 1) ? c/2*t*t*t*t + b : -c/2 * ((t-=2)*t*t*t - 2) + b },
      in_quint: -> (t, b, c, d) { c * (t/=d)*t*t*t*t + b},
      out_quint: -> (t, b, c, d) { c * ((t=t/d-1)*t*t*t*t + 1) + b },
      quint: -> (t, b, c, d) { ((t/=d/2) < 1) ? c/2*t*t*t*t*t + b : c/2*((t-=2)*t*t*t*t + 2) + b },
      in_sine: -> (t, b, c, d) { -c * Math.cos(t/d * (Math::PI/2)) + c + b },
      out_sine: -> (t, b, c, d) { c * Math.sin(t/d * (Math::PI/2)) + b},
      sine: -> (t, b, c, d) { -c/2 * (Math.cos(Math::PI*t/d) - 1) + b },
      in_expo: -> (t, b, c, d) { (t==0) ? b : c * (2 ** (10 * (t/d - 1))) + b},
      out_expo: -> (t, b, c, d) { (t==d) ? b+c : c * (-2**(-10 * t/d) + 1) + b },
      expo: -> (t, b, c, d) { t == 0 ? b : (t == d ? b + c : (((t /= d/2) < 1) ? (c/2) * 2**(10 * (t-1)) + b : ((c/2) * (-2**(-10 * t-=1) + 2) + b))) },
      in_circ: -> (t, b, c, d) { -c * (Math.sqrt(1 - (t/=d)*t) - 1) + b },
      out_circ: -> (t, b, c, d) { c * Math.sqrt(1 - (t=t/d-1)*t) + b },
      circ: -> (t, b, c, d) { ((t/=d/2) < 1) ? -c/2 * (Math.sqrt(1 - t*t) - 1) + b : c/2 * (Math.sqrt(1 - (t-=2)*t) + 1) + b },
      out_back: -> (t, b, c, d, s=1.70158) { ((t/=d/2) < 1) ? c/2*(t*t*(((s*=(1.525))+1)*t - s)) + b : c/2*((t-=2)*t*(((s*=(1.525))+1)*t + s) + 2) + b },
      in_back: -> (t, b, c, d, s=1.70158) { c*(t/=d)*t*((s+1)*t - s) + b },
      back: -> (t, b, c, d, s=1.70158) { ((t/=d/2) < 1) ? c/2*(t*t*(((s*=(1.525))+1)*t - s)) + b : c/2*((t-=2)*t*(((s*=(1.525))+1)*t + s) + 2) + b},
      out_bounce: -> (t, b, c, d) { ((t/=d) < (1/2.75)) ? c*(7.5625*t*t) + b :  (t < (2/2.75)) ? c*(7.5625*(t-=(1.5/2.75))*t + 0.75) + b : (t < (2.5/2.75)) ? c*(7.5625*(t-=(2.25/2.75))*t + 0.9375) + b : c*(7.5625*(t-=(2.625/2.75))*t + 0.984375) + b },
      in_bounce: -> (t, b, c, d) { c - ($easing[:out_bounce].call((d-t), 0, c, d)) + b },
      bounce: -> (t, b, c, d) { (t < d/2) ?  $easing[:in_bounce].call(t*2, 0, c, d) * 0.5 + b : $easing[:in_bounce].call(t*2-d, 0, c, d) * 0.5 + c*0.5 + b }
      # Derived from:
      # https://github.com/danro/jquery-easing/blob/master/jquery.easing.js
      # https://github.com/Michaelangel007/easing/blob/master/js/core/easing.js
    }

    def get_default_opts
      @@default_opts
    end

    def debug(debug=!@@debug)
      @@debug = debug
    end

    def set_eql_keys(keys)
      @@set_keys = keys
    end

    def get_eql_keys
      @@set_keys
    end

    def set_default_opts(opts)
      @@default_opts.merge!(opts)
    end

    def self.set_default_sleep(sleep)
      @@default_sleep[:sleep] = sleep.to_f
    end

    def self.durations
      @@default_durs
    end

    def merge_synth_defaults
      @@default_opts.merge!(Hash[current_synth_defaults.to_a])
    end

    def zrange(func,start,finish,duration,time=nil)
      (1..duration).map { |t| time ? $easing[func].call(t.to_f,start.to_f,(finish-start).to_f, duration.to_f,time.to_f) : $easing[func].call(t.to_f,start.to_f,(finish-start).to_f, duration.to_f) }
    end

    def ziff_to_string(value)
      if value.is_a?(Hash)
        # TODO: Clean this mess up
        ""+((value[:sleep].is_a?(Integer) or value[:sleep].is_a?(Float)) ? @@default_durs.key(value[:sleep]).to_s : value[:sleep].to_s) +
        value[:dot].to_s +
        (!value[:hpcs] ? (value[:octave].is_a?(String) ? value[:octave] : ((value[:octave].is_a?(Integer) && value[:octave]!=0) ? (value[:octave]>0 ? "^"*value[:octave] : "_"*value[:octave].abs) : "" )) : "") +
        value[:add].to_s +
        ((value.key?(:pc) and (value[:pc].to_i>9 or value[:pc].to_i<-9))  ? "=" : "") +
        (value[:note]==:r ? "r" : value[:pc].to_s) +
        (value[:hpcs] ? value[:hpcs].map{ |v|
          (v[:octave].is_a?(String) ? v[:octave] : ((v[:octave].is_a?(Integer) && v[:octave]!=0) ? (v[:octave]>0 ? "^"*v[:octave] : "_"*v[:octave].abs) : "" )) +
          v[:add].to_s +
          ((v[:pc].to_i>9 or v[:pc].to_i<-9) ? "=("+v[:pc].to_s+")" : ""+v[:pc].to_s)
        }.join("") : "") +
        value[:separator].to_s
      else
        value
      end
    end

    def zstring(melody)
      melody.map {|v| ziff_to_string(v) }.join(" ")
    end

    # TODO: Create treetop parser
    # Parses variable syntax and replaces the variables in a string
    # Example: "<x=2[1,2]> x b" -> "21 b"
    # Example with propability: "<0.5%a=1> <0.9%b=2> a b" -> "1 2" or "2" or "1"
    # Example with fallback: "<0.3%d=q1234!=wr> d" -> "q1234" or "wr"
    def replace_variable_syntax(n,rep={})
      n = n.gsub(/\<([0-9]*\.?[0-9]+)?%?(.)=(.*?)(?:(?:!=)(.*?))?\>/) do
        alt_val = $4 ? $4 : ""
        rep_val = (rand < $1.to_f ? $3 : alt_val) if $1
        rep[$2] = parse_generative(rep_val ? rep_val : $3)
        ""
      end
      rep.each do |k,v|
        n.gsub!(/#{Regexp.escape(k)}/,v)
      end
      n
    end

    def expand_zspread(n)
      n = n.gsub(/\{(.+)\}\<(\d+),(\d+),?(\d+)?,?(.+)?\>(\{.+\})?/) do
        a = $1.split(";")
        b = $6.tr("{}","").split(";") if $6
        zspread((a.length>1 ? a : a[0]), $2.to_i, $3.to_i, ($4 ? $4.to_i : 0), ($5 ? $5 : " "),(b ? (b.length>1 ? b : b[0]) : "r"))
      end
    end

    # DEPRECATED
    # Replaces characters with strings or values picked from an array using loop cycle % array length
    def replace_use_params(n,shared)
      if shared[:use] then
        loop_i = shared[:loop_name] ? $zloop_states[shared[:loop_name]][:loop_i] : 0
        shared[:use].each do |key,val|
          if val.kind_of?(Array) then
            n = n.gsub(key.to_s,val[loop_i % val.size].to_s)
          elsif val.kind_of?(String) then
            n = n.gsub(key.to_s,val.to_s)
          end
        end
      end
      n
    end


    # TODO: Document or remove?
    def zgroup(n, opts={}, shared={})
      if n.is_a?(Array)
        if !n[0].is_a?(Hash)
          defaults = shared.merge(opts)
          opts = get_default_opts.merge(opts)
          n = normalize_melody n, opts, defaults
        end
        n = ZiffArray.new(n).deep_clone
        n = n.each_with_index.map {|z,i| apply_transformation(z, opts, 1, i, n.length, true)}
        n = apply_array_transformations n, nil, opts
        print "T: "+zstring(n) if @@debug
        n
      else
        zparse(n,opts,shared)
      end
    end

    # TODO: Document n.times.collect { zgen "(1,[4,6,7])" } etc. or remove?
    def zgen(n, opts={}, shared=get_default_opts)
      defaults = shared.merge(opts)
      opts = defaults.slice(*@@slice_opts_keys)
      n = parse_generative n, (defaults.has_key?(:parse_chords) ? defaults[:parse_chords] : true)
      n = n.squeeze(" ")
      n.split(" ").flatten
    end

    def zparse(n, opts={}, shared={})
      raise "Melody is nil?" if !n

      if n.is_a?(String)

        defaults = shared.merge(opts)
        opts = defaults.slice(*@@slice_opts_keys)

        opt_lambdas = opts.select {|k,v| v.is_a?(Proc) }
        opt_lambdas = opt_lambdas.map {|v| [v[0],v[1].()] }.to_h
        procs = opts.extract!(*opt_lambdas.keys)
        defaults = defaults.merge(procs)

        opt_arrays = opts.delete_if {|v| v.is_a?(Array) or v.is_a?(SonicPi::Core::RingVector) }
        defaults = defaults.merge(opt_arrays)

        opts = get_default_opts.merge(opts)

        parsed_use = defaults.select{|k,v| k.length<2 and /[[:upper:]]/.match(k)} # Parse capital letters from the opts

        if !parsed_use.empty? then
          parsed_use.each do |key,val|
            if (val.is_a? String) or (val.is_a? Integer) then
              n = n.gsub key.to_s, val
              parsed_use.delete(:key)
            end
          end
          defaults.except!(*parsed_use.keys)
          defaults[:use] = defaults[:use] ? shared[:use].merge(parsed_use) : parsed_use
        end

        n = zpreparse(n,defaults.delete(:parsekey)) if defaults[:parsekey]!=nil
        n = n.gsub(/([0-9][0-9])/) {|m| "=#{$1}" } if defaults[:midi] # Hack for midi

        n = expand_zspread(n) # Hack for spread

        defaults[:rules] = defaults.delete(:replace) if defaults[:replace]
        if defaults[:rules] and !shared[:lsystemloop] then
          gen = defaults[:gen] ? defaults[:gen] : 1
          n = lsystem(n,defaults,gen,nil)[gen-1]
        end

        n = parse_generative n, (defaults.has_key?(:parse_chords) ? defaults[:parse_chords] : true)
        print "G: "+n if @@debug

        parsed = parse_ziffers(n, opts, defaults, @@default_durs)
        print "P: "+zstring(parsed) if @@debug
        parsed
      else
        normalize_melody n, opts, shared
      end
    end

    # DEPRECATED
    # Sets ADSR envelope for given note
    def set_ADSR(ziff,adsr)
      note_length = (ziff[:sleep]==0 ? 1 : ziff[:sleep]*1.5)
      ziff[:attack] = adsr[:attack] * note_length if adsr[:attack]!=nil
      ziff[:decay] = adsr[:decay] * note_length if adsr[:decay]!=nil
      ziff[:sustain] = adsr[:sustain] * note_length if adsr[:sustain]!=nil
      ziff[:release] = adsr[:release] * note_length if adsr[:release]!=nil
    end

    def search_list(arr,query)
      result = (Float(query) != nil rescue false) ? arr[query.to_i] : arr.find { |e| e.match( /\A#{Regexp.quote(query)}/)}
      (result == nil ? query : result)
    end

    def zparams(hash, name)
      hash.map{|x| x[name]}
    end

    def clean(ziff)
      ziff.slice(*[:note,:notes,:note_slide,:amp,:amp_slide,:pan,:pan_slide,:attack,:decay,:sustain,:release,:attack_level,:decay_level,:sustain_level,:env_curve,:slide,:pitch,:rate,:on,:cutoff,:res,:env_curve,:vibrato_rate,:vibrato_depth,:vibrato_delay,:vibrato_onset,:width,:freq_band,:room,:reverb_time,:ring,:detune1,:detune2,:noise,:dpulse_width,:pulse_width,:divisor,:norm,:clickiness,:mod_phase,:mod_range,:mod_pulse_width,:mod_phase_offset,:mod_invert_wave,:mod_wave,:detune,:stereo_width,:hard,:vel,:coef,:pluck_delay,:noise_amp,:max_delay_time,:lfo_width,:lfo_rate,:seed,:disable_wave,:range,:invert_wave,:wave,:phase_offset,:phase])
    end

    def play_midi_out(md, opts)
      midi md, opts
    end

    def normalize_sample_arrays(ziff,index,loop_i)
      ziff.each do |key,val|
        if val.is_a?(SonicPi::Core::RingVector) or val.kind_of?(Array) then
          char_key = ziff[:chars] ? ziff[:chars].join("") : ziff[:char]
          ziff[key] = val.tick(char_key+"-"+key.to_s)
        elsif val.is_a? Proc then
          case val.arity
          when 0 then
            ziff[key] = val.()
          when 1 then
            ziff[key] = val.(index)
          when 2 then
            ziff[key] = val.(index, loop_i)
          end
        end
      end
    end

    def zthread(melody, opts={}, defaults={}, loop_i=0)
      in_thread do
        zplay(melody,opts,defaults,loop_i)
      end
    end

    def zplay(melody,opts={},defaults={},loop_i=0)

      loop_name = defaults[:loop_name]

      if !loop_name
        # Extract common options to defaults

       defaults = defaults.merge(opts)
       opts = defaults.slice(*@@slice_opts_keys)

        # TODO: Add global parameter for this
        use_sched_ahead_time defaults[:sched_ahead] ? defaults[:sched_ahead] : 1
        use_arg_bpm_scaling defaults[:use_arg_bpm_scaling] ? defaults[:use_arg_bpm_scaling] : false
      end

      if defaults[:store] and loop_name and $zloop_states[loop_name][:parsed_melody]
        melody = $zloop_states[defaults[:loop_name]][:parsed_melody]
        melody = normalize_melody(melody, opts, defaults)
      elsif melody.is_a? Enumerator then
        enum = melody
        begin
            melody = enum.next
          rescue StopIteration
            stop
        end
        melody = normalize_melody(melody, opts, defaults)
      elsif has_combinatorics(defaults)
          melody = normalize_melody(melody, opts, defaults)
          enum = parse_combinatorics(melody,defaults)
          melody = enum.next if enum.size != 0
      else
          melody = normalize_melody(melody, opts, defaults)
      end

      if defaults[:bpm] then
        if defaults[:run]
          defaults[:run] = [defaults[:run]] if !defaults[:run].is_a?(Array)
          defaults[:run] << {with_bpm: defaults.delete(:bpm)}
        else
          defaults[:run] = [{with_bpm: defaults.delete(:bpm)}]
        end
      end

      loop_i = loop_name ? $zloop_states[loop_name][:loop_i] : loop_i
      loop_n = melody.length*(loop_i+1)

      loop do

        # Default opts for enums
        defaults = $zloop_states[loop_name][:defaults] if loop_name and $zloop_states[loop_name] and $zloop_states[loop_name][:defaults]

        if !opts[:port] and defaults[:run] then
          block_with_effects normalize_effects(defaults[:run]) do
            zplayer(melody,opts,defaults,loop_i)
          end
        else
          zplayer(melody,opts,defaults,loop_i)
        end
        print "Cycle index: "+loop_i.to_s if @@debug and loop_i>0
        break if !enum
        defaults[:loop_i] = loop_i
        melody = normalize_melody enum.next, opts, defaults
        loop_i = loop_i+1
      end
    end

    def zplayer(melody,opts={},defaults={},loop_i=0)
      melody = [melody] if !melody.kind_of?(Array)
      if melody.length==0 then
        $zloop_states.delete(defaults[:loop_name]) if defaults[:loop_name]
        stop
      end
      melody.each_with_index do |ziff,index|
        if !ziff[:skip] and ziff[:rest]
          sleep ziff[:sleep]
          next
        end
        ziff = apply_transformation(ziff, defaults, loop_i, index, melody.length)
      # TODO: Keep or not to keep?
      '''  if ziff[:lambda] then
          ziff[:lambda].() if ziff[:lambda].arity == 0
          ziff[:lambda].(ziff) if ziff[:lambda].arity == 1
          ziff[:lambda].(ziff,index) if ziff[:lambda].arity == 2
          ziff[:lambda].(ziff,index,loop_i) if ziff[:lambda].arity == 3
          ziff[:lambda].(ziff,index,loop_i,melody.length) if ziff[:lambda].arity == 4
        end
        "'''
        if ziff[:methods] then
          ziff[:methods].each do |f|
            in_thread do
              send f[:method][1..], *f[:parameters]
            end
          end
        end

        # TODO: Merge rate not working. Merges too much?
        #ziff = opts.merge(merge_rate(ziff, defaults)) if defaults[:preparsed]

        if defaults[:fade]
          tick_reset(:adjust_amp)
          fade = defaults.delete(:fade)
          fade_from = fade.begin
          fade_to = fade.end
          fade_in = defaults.delete(:fade_in)
          fader = defaults.delete(:fader)
          defaults[:adjust_amp] = zrange((fader ? fader : :quart), fade_from, fade_to, fade_in ? fade_in*melody.length : melody.length)
        end

        if defaults[:adjust_amp] then
          t_index = tick(:adjust_amp)
          ziff[:amp] = defaults[:adjust_amp][t_index] ? defaults[:adjust_amp][t_index] : defaults[:adjust_amp][defaults[:adjust_amp].length-1]
        end

        if ziff[:run_each] then
          block_with_effects normalize_effects(ziff[:run_each],ziff[:char]) do
            play_ziff(ziff,defaults,index,loop_i)
          end
        else
          play_ziff(ziff,defaults,index,loop_i)
        end

        sleep ziff[:sleep] if !ziff[:skip] and !(ziff[:notes] and ziff[:arpeggio])
      end
      # Save loop state
      if defaults[:store] and defaults[:loop_name] then
        $zloop_states[defaults[:loop_name]][:parsed_melody] = melody
        if @@debug then
          print "Stored:"
          print zparams melody, :pc
        end
      end
    end

    def play_ziff(ziff,defaults={},index,loop_i)
      cue ziff[:cue] if ziff[:cue]
      if ziff[:send] then
        send(ziff[:send],ziff)
      elsif ziff[:skip] then
        print "Skipping note"
      elsif ziff[:notes] then
        if ziff[:arpeggio] then
          ziff[:arpeggio].each do |cn|
            cn[:amp] = ziff[:amp] if !cn[:amp] and ziff[:amp]
            if cn[:pcs] then
              arp_chord = cn[:pcs].map{|d| ziff[:notes][d%ziff[:notes].length]}
              arp_notes = {notes: arp_chord}
            else
              arp_notes = {note: ziff[:notes][cn[:pc]%ziff[:notes].length]}
            end
            arp_opts = cn.merge(arp_notes).except(:pcs)
            if ziff[:port] then
              sustain = ziff[:chord_release] ? ziff[:chord_release] : 1
              if arp_notes[:notes] then
                arp_notes[:notes].each do |arp_note|
                  play_midi_out arp_note+cn[:pitch], ziff.slice(:port,:channel,:vel,:vel_f).merge({sustain: sustain})
                end
              else
                play_midi_out arp_notes[:note]+cn[:pitch], ziff.slice(:port,:channel,:vel,:vel_f).merge({sustain: sustain})
              end
            else
              synth (ziff[:chord_synth]!=nil ? ziff[:chord_synth] : (ziff[:synth]!=nil ? ziff[:synth] : current_synth)), clean(arp_opts)
            end
            sleep cn[:sleep]
          end
        else
          if ziff[:port]
            sustain = ziff[:chord_release] ? ziff[:chord_release] : 1
            ziff[:notes].each do |cnote|
              play_midi_out(cnote, ziff.slice(:port,:channel,:vel,:vel_f).merge({sustain: sustain}))
            end
          else
            synth (ziff[:chord_synth]!=nil ? ziff[:chord_synth] : (ziff[:synth]!=nil ? ziff[:synth] : current_synth)), clean(ziff)
          end
        end
      elsif ziff[:port] then
        sustain = ziff[:sustain]!=nil ? ziff[:sustain] : ziff[:release]
        play_midi_out(ziff[:note], ziff.slice(:port,:channel,:vel,:vel_f).merge({sustain: sustain}))
      else
        #slide = ziff.delete(:control)
        if ziff[:sample]!=nil or ziff[:samples]!=nil then
          if defaults[:rate_based] && ziff[:note]!=nil then
            ziff[:rate] = pitch_to_ratio(ziff[:note]-note(ziff[:key]))
          elsif ziff[:pc]!=nil then
            ziff[:pitch] = (scale 0, ziff[:scale], num_octaves: 2)[ziff[:pc]]+(ziff[:octave])*12-0.001
          end
          if ziff[:cut] then
            ziff[:finish] = [0.0,(ziff[:sleep]/(sample_duration (ziff[:sample_dir] ? [ziff[:sample_dir], ziff[:sample]] : ziff[:sample])))*ziff[:cut],1.0].sort[1]
            ziff[:finish]=ziff[:finish]+ziff[:start] if ziff[:start]
          end
          # Normalize sample parameters
          if ziff[:samples]
            ziff[:samples].each do |s|
              sample s, clean(ziff)
              # TODO: Normalize for group of samples?
            end
          else
            # TODO: Lambda's not running in every loop?
            normalize_sample_arrays(ziff,index,loop_i)
            c = sample (ziff[:sample_dir] ? [ziff[:sample_dir], ziff[:sample]] : ziff[:sample]), clean(ziff)
          end
        elsif ziff[:note] or ziff[:notes]
          if ziff[:synth] then
            c = synth ziff[:synth], clean(ziff)
          else
            c = play clean(ziff)
          end
        end
        if ziff[:slide] != nil then
          first = ziff[:slide].clone
          first[:note] = first.delete(:notes)[0]
          first[:release] = ziff[:sleep]*ziff[:slide][:notes].length
          first[:note_slide] = ziff[:note_slide] ? ziff[:note_slide] : 0.9

          if !first[:sample]
            c = play clean(first)
          else
            c = sample (ziff[:sample_dir] ? [ziff[:sample_dir], ziff[:sample]] : ziff[:sample]), clean(ziff)
          end

          slide_sleep = ziff[:sleep]/ziff[:slide][:notes].length
          sleep slide_sleep
          rest = ziff[:slide][:notes]
          rest.each_with_index do |cnote,i|
             slide_ziff = ziff[:slide].clone
             slide_ziff[:note] = slide_ziff[:notes][i]
             slide_ziff[:pc] = slide_ziff[:pcs][i]
             slide_ziff[:pitch] = (scale 0, slide_ziff[:scale], num_octaves: 2)[slide_ziff[:pc]]+(slide_ziff[:octave] ? (ziff[:octave]*12) : 0) if slide_ziff[:sample]!=nil && slide_ziff[:pc]!=nil

              cc = clean(slide_ziff).except(:attack,:release,:sustain,:decay,:notes,:pcs)
              control c, cc
              sleep slide_sleep
          end
        end
      end
    end

    def normalize_effects(run,char=nil)
      run = [run] if run.is_a?(Hash)
      run = [{with_fx: run}] if run.is_a?(Symbol)
      run.map do |effect|
        dup = {}
        effect_name = effect[:with_fx] ? "run-"+effect[:with_fx].to_s : "run"
        name = char ? char+"-"+effect_name : effect_name
        effect.each do |key, val|
        if val.is_a?(SonicPi::Core::RingVector) or val.kind_of?(Array) then
          dup[key] = val.tick(name+"-"+key.to_s)
        elsif val.is_a? Proc then
            case val.arity
            when 0 then
              dup[key] = val.()
            when 1 then
              dup[key] = val.(tick(name+"-"+key.to_s))
            end
          end
        end
        if dup.size>0 then
          effect.clone.merge(dup)
        else
          effect
        end
      end
    end

    def normalize_melody(melody, opts, defaults)
      defaults[:normalized] = true

      if melody.is_a?(Proc)
        loop_i = defaults[:loop_name] ? $zloop_states[defaults[:loop_name]][:loop_i] : 0
        case melody.arity
        when 0 then
          melody = melody.()
        when 1 then
          melody = melody.(loop_i)
        end
      end

      if melody.is_a?(String)
        return zparse(melody,opts,defaults)
      elsif melody.is_a?(Symbol) and melody == :r
        return zparse("r",opts,defaults)
      elsif melody.is_a?(Numeric) # zplay 1 OR zmidi 85
        if defaults[:midi] then
          opts[:note] = melody
        else
          defaults[:parse_chords]=false if !defaults.has_key?(:parse_chords)
          return zparse(melody.to_s,opts,defaults)
        end
      elsif melody.is_a?(Array)
        defaults = defaults.merge(opts)
        opts = defaults.slice(*@@slice_opts_keys)
        melody = zarray(melody,opts,defaults)
        melody = apply_array_transformations melody, opts, defaults
        return melody
      elsif melody.is_a?(Hash)
        return [melody]
      else
        raise "Could not parse given melody!"
      end
    end

    def create_loop_opts(opts, loop_opts)
      opts.each do |key,val|
        if key.to_s.length>1 and val.is_a? Proc then
          loop_opts[:lambdas] = {} if !loop_opts[:lambdas]
          loop_opts[:lambdas][key] = opts.delete(key)
        end
      end
    end

    def eval_loop_opts(opts,loop_opts)
      if loop_opts[:lambdas] then
        loop_opts[:lambdas].each do |key, val|
          opts[key] = val.() if val.arity == 0
          opts[key] = val.(loop_opts[:loop_i]) if val.arity == 1
        end
      end
    end

    # Looper for multi line notation
    def ziffers(input, opts={}, shared={})
      input = unroll_repeats input
      merge_opts = {}
      live_loop :ziffers do
        stop if opts[:stop]
        zplay_multi_line(input, opts, shared, merge_opts)
      end
    end

    def ziff(input, opts={}, shared={})
      input = unroll_repeats input
      parsed = parse_rows(input)
      length = parsed[:rows][0].length
      merge_opts = {}
      length.times do |i|
        merge_opts = zplay_multi_line(input,opts, shared, merge_opts)
      end
    end

    def zplay_multi_line(input, opts={}, shared={},merge_opts={})
      tick(:multi_line)
      parsed = parse_rows(input)
      measures = parsed[:rows].transpose
      row_options = parsed[:options]

      # Parse measures
      ziffs = measures.ring[look(:multi_line)].map.with_index do |m,i|
        if m
          m_index = parsed[:shared_options].filter_map.with_index { |e, i| i if !e }
          shared_options = parsed[:shared_options].flatten[0..m_index[i]].compact.last
          merge_opts.merge!(shared_options) if shared_options

          ziff_opts = opts.merge(merge_opts)
          if row_options && row_options[i]
            row_opts = row_options[i].ring[look(:multi_line)]
            ziff_opts = row_opts ? ziff_opts.merge(row_opts) : ziff_opts
          end
          zparse m, ziff_opts, shared
        end
      end

      # Find longest measure
      max = ziffs.map{|v| v ? v.duration : 0 }
      max, max_i = max.each_with_index.max
      blocking_melody = ziffs[max_i]
      ziffs[max_i] = nil

      ziffs.each_with_index do |z,i|
        zthread z, opts, shared if z
      end

      zplay blocking_melody, opts, shared

      merge_opts
    end

    def parse_rows(input)
      lines = input.split("\n").to_a.filter {|v| !v.strip.empty? }
      parameters = lines.map {|l| l.split("/") }
      rows = parameters.map{|p|p[0]}.filter {|v| !v.strip.empty? }.map {|l| l.split("|").filter {|v| !v.strip.empty? } }
      rows_length = rows.map(&:length).max
      rows = rows.map {|v| v.length<rows_length ? v+Array.new(rows_length-v.length){ nil } : v }
      shared_options = parameters.map {|p| p[1].split("|").map{|sp| (sp && sp.strip.empty? ? nil : parse_params(sp))} if p[0]=="" }
      options = parameters.map{|p| p[0].empty? ? false : (p[1] ? p[1].split("|").map{|sp| sp && sp.strip.empty? ? nil : parse_params(sp)} : nil) }.filter {|v| v!=false }
      {rows: rows, shared_options: shared_options, options: options}
    end

    def parse_tracks(input, opts={})
      parameters = input.split("/")
      row = parameters[0] if parameters and parameters[0] and parameters[0].strip!=""
      row_options = parameters[1].split("|").map {|v| v.strip.empty? ? nil : parse_params(v,opts) } if row and parameters[1]
      shared_options = parameters[1].split("|").map {|v| v.strip.empty? ? nil : parse_params(v,opts) } if !row and parameters[1]
      row_options = row_options[0] if row_options and row_options.length == 1
      shared_options = shared_options[0] if shared_options and shared_options.length == 1
      result = {}
      result[:tracks] = row.split("|").filter {|v| !v.strip.empty? } if row
      result[:options] = row_options if row_options
      result[:shared_options] = shared_options if shared_options
      result
    end

    # Looper for track notation
    def ztracker(m, opts={}, shared=nil)
      live_loop :ztracker do
        stop if opts[:stop]
        shared = zplay_tracks(m, opts, shared)
      end
    end

    def ztracks(input, opts={}, shared={})
      length = input.split("|").to_a.filter {|v| !v.strip.empty? }.length
      length.times do |i|
        shared = zplay_tracks(input,opts, shared)
      end
    end

    # Plays tracks notation
    def zplay_tracks(m, opts={}, shared=nil)
      line = m.split("\n").to_a.filter {|v| !v.strip.empty? }.ring[tick(:ztracker)]
      result = zparse_tracks line, opts, shared, look(:ztracker)

      while result[:shared_opts] do

        if !shared
          shared = result[:shared_opts]
        elsif shared.is_a?(Hash)
          if result[:shared_opts].is_a?(Hash)
            shared = shared.merge(result[:shared_opts])
          elsif result[:shared_opts].is_a?(Array)
            result[:shared_opts][0] = result[:shared_opts][0].merge(shared)
            shared = result[:shared_opts]
          end
        elsif shared.is_a?(Array)
          shared = result[:shared_opts].map.with_index {|s,i| shared[i] ? shared[i].merge(s) : shared[i] = s } if result[:shared_opts].is_a?(Array)
          shared = shared.map {|s| s.merge(result[:shared_opts]) } if result[:shared_opts].is_a?(Hash)
        end
        line = m.split("\n").to_a.filter {|v| !v.strip.empty? }.ring[tick(:ztracker)]
        result = zparse_tracks line, opts, shared, look(:ztracker)
      end

      ziffs = result[:zthreads]
      blocking_melody = result[:zthreads].select {|v| v[:blocking] }[0][:blocking]

      ziffs.each_with_index do |z,i|
        zthread z[:thread], opts, z[:merged_opts], look(:ztracker) if z and z[:thread]
      end

      zplay blocking_melody[:thread], opts, blocking_melody[:merged_opts], look(:ztracker)

      shared
    end

    # Parse tracks to threads and blocking melody
    def zparse_tracks(row, opts, shared_opts=nil, loop_i=0)
      parsed = parse_tracks(row,opts)

      return {shared_opts: parsed[:shared_options]} if parsed[:shared_options]

      row_opts = parsed[:options]
      tracks = parsed[:tracks]

      ziffs = tracks.map.with_index do |t,i|
        merged_opts = opts
        merged_opts = (shared_opts.is_a?(Array)) ? (shared_opts[i] ? merged_opts.merge(shared_opts[i]) : merged_opts) : merged_opts.merge(shared_opts) if shared_opts
        merged_opts = (row_opts.is_a?(Array)) ? (row_opts[i] ? merged_opts.merge(row_opts[i]) : merged_opts) : merged_opts.merge(row_opts) if row_opts

        z = zparse t.strip, merged_opts, {loop_i: loop_i}
        {thread: z, merged_opts: merged_opts}
      end

        # Find longest measure
        max = ziffs.map{|v| v ? v[:thread].duration : 0 }
        max, max_i = max.each_with_index.max
        blocking_melody = ziffs[max_i]
        ziffs[max_i] = {blocking: blocking_melody}

        return {zthreads: ziffs}
    end

    # Parses track string to tracks and options
    def parse_tracks(input, opts={})
      parameters = input.split("/")
      row = parameters[0] if parameters and parameters[0] and parameters[0].strip!=""
      row_options = parameters[1].split("|").map {|v| v.strip.empty? ? nil : parse_params(v,opts) } if row and parameters[1]
      shared_options = parameters[1].split("|").map {|v| v.strip.empty? ? nil : parse_params(v,opts) } if !row and parameters[1]
      row_options = row_options[0] if row_options and row_options.length == 1
      shared_options = shared_options[0] if shared_options and shared_options.length == 1
      result = {}
      result[:tracks] = row.split("|").filter {|v| !v.strip.empty? } if row
      result[:options] = row_options if row_options
      result[:shared_options] = shared_options if shared_options
      result
    end

    # Original looper
    def zloop(name, melody, opts={}, defaults={})
      defaults[:loop_name] = name

      defaults = defaults.merge(opts)
      opts = defaults.slice(*@@slice_opts_keys)

      clean_loop_states # Clean unused loop states
      $zloop_states.delete(name) if opts.delete(:reset)

      raise "First parameter should be loop name as a symbol!" if !name.is_a?(Symbol)
      raise "Third parameter should be options as hash object!" if !opts.kind_of?(Hash)
      if !$zloop_states[name] then # If first time
        $zloop_states[name] = {}
        $zloop_states[name][:loop_i] = 0
      end
      $zloop_states[name][:cycle] = defaults.delete(:cycle) if defaults[:cycle]

      create_loop_opts(opts,$zloop_states[name])

      if defaults[:phase] then
        defaults[:phase] = defaults[:phase].to_a if (defaults[:phase].is_a? SonicPi::Core::RingVector)
      end

      #if melody.is_a?(Array) && melody[0].is_a?(Hash) then
      #  defaults[:preparsed] = true
      if melody.is_a?(Enumerator) or ((defaults[:parse] or (has_combinatorics(defaults)) and !$zloop_states[name][:enumeration]) and (melody.is_a?(String) and !melody.start_with? "//") and !defaults[:seed])

        if melody.is_a? Enumerator then
          enumeration = melody
        else
          parsed_melody = normalize_melody melody, opts, defaults
          enumeration = parse_combinatorics parsed_melody, defaults
        end

        if enumeration then
          $zloop_states[name][:enumeration] = enumeration.cycle
        end

      end

      $zloop_states[name][:defaults] = opts.merge(defaults)

      live_loop name, defaults.slice(:init,:auto_cue,:delay,:sync,:sync_bpm,:seed) do

        if defaults[:stop] and ((defaults[:stop].is_a? Numeric) and $zloop_states[name][:loop_i]>=defaults[:stop]) or ([true].include? defaults[:stop]) or (melody.is_a?(String) and (melody.start_with? "//" or melody.start_with? "# ")) then
          $zloop_states.delete(name)
          stop
        end

        use_sched_ahead_time (defaults[:sched_ahead] ? defaults[:sched_ahead] : 1)
        use_arg_bpm_scaling defaults[:use_arg_bpm_scaling] ? defaults[:use_arg_bpm_scaling] : false
        eval_loop_opts(opts,$zloop_states[name])
        sync defaults[:wait] if defaults[:wait]

        if defaults[:phase] then
          phase = defaults[:phase].is_a?(Array) ? defaults[:phase][$zloop_states[name][:loop_i] % defaults[:phase].length] : defaults[:phase]
          sleep phase
        end

        if $zloop_states[name][:cycle] then
          loop_opts = opts.clone
          cycle_array = ($zloop_states[name][:cycle].is_a? Array) ? $zloop_states[name][:cycle] : [$zloop_states[name][:cycle]]
          cycle_array.each do |value|
            raise "Expected :to in :cycle object!" if !value[:at]
            mod_cycles = ($zloop_states[name][:loop_i]+1) % value[:at]
            if value[:range] and value[:range].is_a?(Range) then
              mod_cycles = value[:at] if mod_cycles == 0
              if mod_cycles >= value[:range].begin and mod_cycles <= value[:range].end then
                loop_opts = get_loop_opts(value.except(:at,:range),loop_opts,$zloop_states[name][:loop_i])
              end
            elsif mod_cycles == 0 then
              loop_opts = get_loop_opts(value.except(:at),loop_opts,$zloop_states[name][:loop_i])
            end
          end
        end

        if $zloop_states[name][:enumeration] then
          enum = $zloop_states[name][:enumeration]
          zplay enum, opts, defaults
        elsif parsed_melody
          zplay parsed_melody, opts, defaults
        else
          if defaults[:rules] and !defaults[:gen] then
            defaults[:lsystemloop] = true
            $zloop_states[name][:melody] = melody if !$zloop_states[name][:melody]
            $zloop_states[name][:melody] = (lsystem($zloop_states[name][:melody], opts, 1, $zloop_states[name][:loop_i]))[0]
            zplay $zloop_states[name][:melody], opts, defaults
          else
            if loop_opts then
                zplay loop_opts[:pattern] ? loop_opts[:pattern] : melody, loop_opts, defaults
            else
                zplay melody, opts, defaults
            end
          end
        end
        $zloop_states[name][:loop_i] += 1
      end
    end

    def has_combinatorics(opts)
      return (opts[:permutation] or opts[:iteration] or opts[:combination])
    end

    # Parses enum or returns nil
    def parse_combinatorics(parsed_melody, opts)
      iteration = opts.delete(:iteration)
      combination = opts.delete(:combination)
      permutation = opts.delete(:permutation)
      repeated = opts.delete(:repeated)
      transposed = opts.delete(:transpose_enum)
      if permutation or combination or iteration then
        if permutation then
          enumeration = repeated ? parsed_melody.repeated_permutation(permutation) : parsed_melody.permutation(permutation)
        elsif combination
          enumeration = repeated ? parsed_melody.repeated_combination(combination) : parsed_melody.combination(combination)
        elsif iteration
          enumeration = parsed_melody.each_cons(iteration)
        end
        if enumeration.size == 0 then
          print "Permutation out of bounds"
        elsif
           print "Enumeration size: "+enumeration.size.to_s
        end
        if opts.delete(:transform_enum) then
          enum_arr = apply_array_transformations enumeration.to_a, opts, defaults
          enum_arr = enum_arr.transpose if transposed
          enumeration = enum_arr.to_enum
        end
        return enumeration
      end
      return nil
    end

    def get_loop_opts(when_opts, opts, loop_i)
      when_opts.each do |key,val|
        if val.is_a? Proc then
          opts[key] = val.() if val.arity == 0
          opts[key] = val.(loop_i) if val.arity == 1
        else
          opts[key] = val
        end
      end
      opts
    end

    def clean_loop_states()
      if !$zloop_states then
        $zloop_states = {}
      else
        $zloop_states = $zloop_states.select{|name| get_live_loops.include?(name)}
      end
    end

    def get_live_loops(live_loops=[]) # TODO: Bit hacky. Maybe there is a better way?
      Thread.list.each do |t|
        sonic_thread = t.thread_variable_get(:sonic_pi_system_thread_locals)
        if sonic_thread then
          named_thread = sonic_thread.get(:sonic_pi_local_spider_users_thread_name)
          if named_thread then
            live_loops.push(named_thread.to_s.sub("live_loop_","").to_sym)
          end
        end
      end
      live_loops
    end

    def get_loop_states
      $zloop_states
    end

    def reset_loop_states(states={})
      $zloop_states = states
    end

    def block_with_effects(x,&block)
      raise ":run should be array of hashes" if x and !x.kind_of?(Array)
      if x.length>0 then
        n = x.shift
        if n[:with_fx] then
          with_fx n[:with_fx], n do
            block_with_effects(x,&block)
          end
        elsif n[:with_swing]
          with_swing n[:with_swing], n do
            block_with_effects(x,&block)
          end
        elsif n[:with_bpm]
          with_bpm n[:with_bpm] do
            block_with_effects(x,&block)
          end
        elsif n[:density]
          density n[:density ] do
            block_with_effects(x,&block)
          end
        elsif n[:with_cent_tuning]
          with_cent_tuning n[:with_cent_tuning] do
            block_with_effects(x,&block)
          end
        elsif n[:with_octave]
          with_octave n[:with_octave] do
            block_with_effects(x,&block)
          end
        end
      else
        yield
      end
    end

    def merge_rate(ziff, opts)
      ziff.merge(opts) {|_,a,b| (a.is_a? Numeric) ? a * b : b }
    end

    # TODO: Create rule for this that handles cycles
    def zspread ziff, x, y, rotate=0, join=" ", offbeat="r"
      cycleZ = ziff.kind_of?(Array)
      cycleO = offbeat.kind_of?(Array)
      ci = -1
      si = -1
      arr = spread(x,y)
      .to_a
      .rotate(-rotate)
      .each_with_index
      .map do |n,i|
        if n
          if cycleZ
            ziff[(ci+=1)%ziff.length]
          else
            ziff
          end
        else
          if cycleO
            offbeat[(si+=1)%offbeat.length]
          else
            offbeat
          end
        end
      end
      arr.join(join)
    end

    def lgen(ax,rules,gen)
      r = ax
      n = lsystem ax, rules, gen
      r+n.join
    end

    def lsystem(ax,opts,gen,loopGen)
      rules = opts[:rules]
      gen.times.collect.with_index do |i|
        i = loopGen if loopGen # If lsystem is used in loop instead of gens
        ax = rules.each_with_object(ax.dup) do |(k,v),s|
          v = v[i] if (v.is_a? Array or v.is_a? SonicPi::Core::RingVector) # [nil,"1"].ring -> every other
          if v then
            s.gsub!(/{{.*?}}|(#{k.is_a?(String) ? Regexp.escape(k) : k})/) do |m|
            g = Regexp.last_match.captures
            if g[0] and !g[0].empty? then # If there is at least one match
              if v.is_a?(Proc) or v.respond_to?(:call)
                if v.arity == 1 then
                  rep = v.(i).to_s
                elsif v.arity == 2
                  rep = v.(i,g).to_s
                else
                  rep = v.().to_s
                end
              else # If not using lambda
                rep = replace_variable_syntax(v)
                rep = g.length>1 ? rep.gsub(/\$([1-9])/) {g[Regexp.last_match[1].to_i]} : rep.gsub("$",m)
                rep = parse_generative(rep)
              end
              "{{#{rep}}}" # Escape
            else
              m # If escaped
            end
          end
        end
      end
      ax = ax.gsub(/{{(.*?)}}/) {$1}
      ax
    end
  end

  def zpreparse(n,key)
    noteList = ["c","d","e","f","g","a","b"]
    key = (key.is_a? Symbol) ? key.to_s.chars[0].downcase : key.chars[0].downcase
    ind = noteList.index(key)
    noteList = noteList[ind...noteList.length]+noteList[0...ind]
    #n.chars.map { |c| noteList.index(c)!=nil ? noteList.index(c) : c  }.join('')
    n.gsub(/[cdefgab]\b/) {|c| noteList.index(c).to_s }
  end

  def zarray(arr, opts={}, defaults={})
    opts = get_default_opts.merge(opts)
    if arr and arr.is_a?(Array) and arr[0].class!=Ziffers::ZiffArray
      zmel=[]
      arr.each do |item|
        if item.is_a? Array then
          zmel.push note_array_to_hash(item,opts)
        elsif item.is_a? Numeric then
            #opts = defaults.merge!(opts) Not working with plain arrays?
            ziff = get_ziff(item, opts[:key], opts[:scale], opts[:octave] ? opts[:octave] : 0)
            ziff.merge!(opts) { |key, important, default| important }
            zmel.push(ZiffHash[ziff])
        elsif item.is_a? Hash then
          zmel.push(ZiffHash[item])
        end
      end
      ZiffArray.new(zmel)
    else
      arr # If already ZiffArray
    end
  end

  def note_array_to_hash(obj,opts=get_default_opts)
    defObj = [0,opts[:sleep],opts[:key],opts[:scale],opts[:release]]
    arrayOpts = [:note,:sleep,:key,:scale,:release]
    obj.each_with_index { |item,index| defObj[index] = item }
    defObj[0] = get_note_from_dgr(defObj[0], defObj[2], defObj[3])
    opts.merge(Hash[arrayOpts.zip(defObj)])
  end

  # TRANSFORMATIONS

  def apply_array_transformations(melody, opts, defaults, loop_i=0)
    loop_i = defaults[:loop_i] if defaults[:loop_i]
    defaults.each do |key,val|
      if val.is_a? Proc then
        if val.arity == 1
          val = val.(loop_i)
        elsif val.arity == 2
          # TODO: Ugly hack. Better logic is needed when note_i not available
          val = val.(loop_i, 0)
        else
          val = val.()
        end
      end
      case key
      when :retrograde then
        melody = melody.retrograde val
      when :swap then
        melody = melody.swap *val
      when :rotate then
        melody = melody.rotate(val)
      when :deal then
        melody = melody.deal.flatten
      when :mirror then
        melody = melody.mirror
      when :reverse then
        melody = melody.reverse
      when :reflect then
        melody = melody.reflect
      when :subset then
        melody = (val.is_a? Numeric) ? ZiffArray.new(melody[val]) : melody[val]
      when :inject then
        melody = melody.inject(val.is_a?(Array) ? val : (normalize_melody val, opts, defaults)){|a,j| a.flat_map{|n| [n,augment(j, n)]}}
      when :zip then
        melody = melody.zip(val.is_a?(Array) ? val : (normalize_melody val, opts, defaults)).flatten
      when :append then
        melody = melody + (val.is_a?(Array) ? val : (normalize_melody val, opts, defaults))
      when :prepend then
        melody = (val.is_a?(Array) ? val : (normalize_melody val, opts, defaults)) + melody
      when :shuffle then
        melody = ([true].include? val) ? melody.shuffle : (melody[val] = val[val].shuffle)
      when :drop then
        melody = melody.slice!(val)
      when :slice then
        melody = melody.slice(val)
      when :pop then
        if [true].include? val
          melody = melody.pop
        else
          melody = melody.pop(val)
        end
      when :shift
        if [true].include? val
          melody = melody.shift
        else
          melody = melody.shift(val)
        end
      when :pick
        melody = melody.pick(val)
      when :stretch
        melody = melody.stretch
      when :operation
        if defaults[:set]
          melody = melody.set_operation, val, defaults[:set]
        end
      when :superset
        melody = melody.superset(val).flatten
      when :order_transform
        melody = send(val, melody, loop_i+(loop_i*melody.length))
      when :rhythm
        melody = melody.modify_rhythm val, loop_i+(loop_i*melody.length)
      end
    end
    return melody
  end

  def apply_transformation(ziff, defaults, loop_i=0, note_i=0, melody_size=1)
    if defaults[:apply]
      apply_all = defaults[:apply].is_a?(Array) ? defaults[:apply] : [defaults[:apply]]
      apply_all.each do |apply|
        if ((!apply[:at] and !apply[:mod]) or (apply[:at].is_a?(Integer) and apply[:at]==(note_i)) or (apply[:mod].is_a?(Integer) and (note_i+1+(loop_i*melody_size)) % apply[:mod] == 0) or (apply[:at].is_a?(Array) and apply[:at].include?(note_i)) or (apply[:at].is_a?(Range) and apply[:at] === (note_i)))
          with_key = apply.select {|k,v| k.to_s.start_with?("with_") }
          if !with_key.empty?
            fx_hash = {:run_each => apply.except(*[:at, :mod]) }
            apply = fx_hash
          end
          defaults = defaults.dup
          defaults = defaults.except!(:apply).merge(apply)
        end
      end
    end
    defaults.each do |key,val|

      if val.is_a? Proc then
        if val.arity == 1
          val = val.(note_i)
        elsif val.arity == 2
          val = val.(note_i, loop_i)
        else
          val = val.()
        end
        ziff[key] = val
      end

      if val.is_a?(Array) and ![:scale,:run,:run_each,:apply].include?(key)
        val = val.ring[loop_i*melody_size+note_i]
        ziff[key] = val
      elsif val.is_a? SonicPi::Core::RingVector
        val = val[loop_i*melody_size+note_i]
        ziff[key] = val
      end

      case key
      when :key, :scale
        if ziff[key] != val
          ziff[key] = val
          ziff.update_note
        end
      when :octave
        if ziff[:octave]
          ziff[:octave] += val
        else
          ziff[:octave] = val
        end
        ziff.update_note
      when :chord_sleep
        ziff[:sleep] = val if ziff[:notes]
      when :transpose then
        ziff = ziff.transpose val
      when :inverse then
        ziff = ziff.inverse val
      when :augment
        ziff = ziff.augment val
      when :flex
        ziff = ziff.flex val
      when :silence
        ziff = ziff.silence val
      when :harmonize
        ziff = ziff.harmonize val, ziff[:compound] ? ziff[:compound] : 0
      when :detune
        ziff = ziff.detune val
      when :object_transform
        ziff = send(val,ziff,loop_i,note_i,melody_size)
      else # :synth, :amp, :release, :sustain, :decay, :attack, :sleep, :pan, :res, :cutoff, etc
        ziff[key] = val
      end
    end
    return ziff
  end

  def z0(ziff="//", opts={})  zloop(:z0,ziff,opts) end
    def z1(ziff="//", opts={})  zloop(:z1,ziff,opts) end
      def z2(ziff="//", opts={})  zloop(:z2,ziff,opts) end
        def z3(ziff="//", opts={})  zloop(:z3,ziff,opts) end
          def z4(ziff="//", opts={})  zloop(:z4,ziff,opts) end
            def z5(ziff="//", opts={})  zloop(:z5,ziff,opts) end
              def z6(ziff="//", opts={})  zloop(:z6,ziff,opts) end
                def z7(ziff="//", opts={})  zloop(:z7,ziff,opts) end
                 def z8(ziff="//", opts={})  zloop(:z8,ziff,opts) end
                  def z9(ziff="//", opts={})  zloop(:z9,ziff,opts) end
               def z10(ziff="//", opts={})  zloop(:z10,ziff,opts) end
            def z11(ziff="//", opts={})  zloop(:z11,ziff,opts) end
          def z12(ziff="//", opts={})  zloop(:z12,ziff,opts) end
        def z13(ziff="//", opts={})  zloop(:z13,ziff,opts) end
          def z14(ziff="//", opts={})  zloop(:z14,ziff,opts) end
            def z15(ziff="//", opts={})  zloop(:z15,ziff,opts) end
              def z16(ziff="//", opts={})  zloop(:z16,ziff,opts) end
                def z17(ziff="//", opts={})  zloop(:z17,ziff,opts) end
                  def z18(ziff="//", opts={})  zloop(:z18,ziff,opts) end
                    def z19(ziff="//", opts={})  zloop(:z19,ziff,opts) end
                      def z20(ziff="//", opts={})  zloop(:z20,ziff,opts) end

  end

include Ziffers
