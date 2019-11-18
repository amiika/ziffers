print "Ziffers 1.3: The return of the degrees"

module Ziffers

  @@control_chars = {
    'A': :amp,
    'C': :attack,
    'P': :pan,
    'D': :decay,
    'S': :sustain,
    'R': :release,
    'Z': :sleep,
    'X': :chord_sleep,
    'I': :pitch,
    'K': :key,
    'L': :scale,
    '~': :note_slide,
    'i': :chord,
    'v': :chord,
    '%': :chord_invert,
    'O': :channel,
    'G': :arpeggio,
    "=": :eval
  }

  @@default_durs = {
    'm': 8.0, # 15360
    'k': 5.333333333333333, # 10240
    'l': 4.0, # 7680
    'p': 2.666666666666667, # 5120
    'd': 2.0, # 3840
    'c': 1.333333333333333, # 2560
    'w': 1.0, # 1920
    'y': 0.6666666666666667, # 1280
    'h': 0.5, # 960 - 1/2
    'n': 0.3333333333333333, # 640
    'q': 0.25, # 480 - 1/4
    'a': 0.1666666666666667, # 320
    'e': 0.125, # 240 - 1/8
    'f': 0.0833333333333333, # 160
    's': 0.0625, # 120 - 1/16
    'x': 0.0416666666666667, # 80
    't': 0.03125, # 60 - 1/32
    'g': 0.0208333333333333, # 40
    'u': 0.015625, # 30 - 1/64
    'j': 0.0104166666666667, # 20
    'z': 0.0 # 0
  }

  @@default_opts = {
    :key => :c,
    :scale => :major,
    :release => 1.0,
    :sleep => 1.0,
    :pitch => 0.0,
    :amp => 1,
    :pan => 0,
    :skip => false
  }

  @@default_keys = [:run,:store, :rate_based, :adjust, :transform_enum, :transform_single, :order_transform, :object_transform, :iteration, :combination, :permutation, :mirror, :reflect, :reverse, :transpose, :repeated, :subset, :rotate, :detune, :augment, :inject, :zip, :append, :prepend, :pop, :shift, :shuffle, :pick, :stretch, :drop, :slice, :flex, :swap, :retrograde, :silence, :division, :compound, :harmonize, :rhythm]

  @@debug = false
  @@degree_based = false
  @@rmotive_lengths = nil

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

  def set_degree_based(degrees=!@@degree_based)
    @@degree_based = degrees
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
    (0..duration).map { |t| time ? $easing[func].call(t.to_f,start.to_f,(finish-start).to_f, duration.to_f,time.to_f) : $easing[func].call(t.to_f,start.to_f,(finish-start).to_f, duration.to_f) }
  end

  # Parses variable syntax and replaces the variables in a string
  # Example: "<x=2[1,2]> x b" -> "21 b"
  # Example with propability: "<0.5%a=1> <0.9%b=2> a b" -> "1 2" or "2" or "1"
  # Example with fallback: "<0.3%d=q1234!=wr> d" -> "q1234" or "wr"
  def replace_variable_syntax(n,rep={})
    n = n.gsub(/\<([0-9]*\.?[0-9]+)?%?(.)=(.*?)(?:(?:!=)(.*?))?\>/) do
      alt_val = $4 ? $4 : ""
      rep_val = (rand < $1.to_f ? $3 : alt_val) if $1
      rep[$2] = replace_random_syntax(rep_val ? rep_val : $3)
      ""
    end
    rep.each do |k,v|
      n.gsub!(/#{Regexp.escape(k)}/,v)
    end
    n
  end

  # Replaces random syntax in a string
  # Example: "[1,2] (1..3)?" -> "2 312"
  def replace_random_syntax(n)
    n = n.gsub(/\[(.*?)\]\*?(\d+)?/) do # Replace random values inside []
      repeat = $2 ? $2.to_i : 1
      chooseArray = $1.split(",")
      result = ""
      repeat.times do
        result+=chooseArray.choose
      end
      result
    end
    n = replace_random_sequence(n)
    n = expand_multi_syntax(n)
    n
  end

  def expand_repeat_syntax(n)
    n = n.gsub(/:(.*?):(\d*)/) do
      if $2.empty? then
        ([$1]*2).join("|")
      else
        ([$1]*$2.to_i).join("|")
      end
    end
  end

  def expand_multi_syntax(n)
    n = n.gsub(/([A-Z]+|[0-9]+|{.*})(\+|\/)(\d+)/) do
      if $2=="+" then
        (($1.tr("{}","")+" ")*$3.to_i).strip
      else
        "("+(($1.tr("{}","")+" ")*$3.to_i).strip+")"
      end
    end
  end

  # Replaces random sequence syntax in a string
  # Example: "(12,23) (1..3)*2" -> "19 123231"
  # Random syntax and this method is work in progress and will change often
  def replace_random_sequence(n)
    return n if !n.include?("(")
    # Debug: https://www.debuggex.com/r/1VusJWIiV_hRy3zt
    n = n.gsub(/\(((-?\d+)\.\.(\d+)|(-?\d+),(\d+)|(\.\.\d+))\)\+?(\d+)?(\?)?(\d+)?@?([1-9.\(\)\+\?]+)?(%[\w])?\^?([a-z]+)?\*?(\d+)?(?:'(.*)')?/) do
      m = Regexp.last_match.captures
      sequence = true
      resultArr=[]
      (m[12] ? m[12].to_i : 1).times do # *3
        nArr = m[5].chars.drop(2).map(&:to_i) if m[5] # (1234)
        if m[1] && m[2] then # 1..7 +2
          s = m[1].to_i
          e = m[2].to_i
          ms = s>e ? e : s # 1..7
          me = e>s ? e : s # 7..1
          nArr = (m[6] ? (ms..me).step(m[6].to_i).to_a : (ms..me).to_a)
          nArr = nArr.reverse if s>e
        end
        if m[3] && m[4] then # 1,3
          nArr = rrand_i(m[3].to_i,m[4].to_i).to_s.chars
          sequence = false
        end
        nArr = nArr.shuffle if m[7] # ?
        nArr = nArr.take(m[8].to_i) if m[8] # ?3
        nArr = nArr.inject(replace_random_sequence(m[9]).split("").map(&:to_i)) {|a,j| a.flat_map{|n|[n,n+j]}} if m[9] # @(4)
        nArr = nArr + (m[10]=="%s" ? nArr.drop(1).reverse.drop(1) : m[10]=="%r" ? nArr.reverse.drop(1) : nArr.reverse) if m[10] # %
        nArr = nArr.join("").split("")
        lArr = m[11].chars if m[11] #^qwe
        nArr = (lArr.length<nArr.length ? lArr*(nArr.length/lArr.length) : lArr).zip(nArr) if lArr
        resultArr += nArr
      end
      m[13] ? resultArr.join(m[13]) : sequence ? resultArr.join(' ') : resultArr.join('')
    end
    n
  end

  # Parses ziffers notation to Hash array
  # Example "1 2"->[{degree:1, key: :c},{degree:2}] ... etc.
  def zparse(n,opts={},shared={})
    notes, noteBuffer, controlBuffer, customChord, customChordDegrees, subList, sub = Array.new(7){ [] }
    loop, dc, ds, escape, quoted, skip, slideNext, negative, degree_based = false, false, false, false, false, false, false, false, false
    stringFloat = ""
    dotLength = 1.0
    sfaddition, dot, loopCount, note = 0, 0, 0, 0, 0
    escapeType = nil
    if opts[:degrees] then
        degree_based = opts.delete(:degrees)
    end
    midi = opts.key?(:midi) ? opts.delete(:midi) : false
    if !midi then
      shared[:groups] = (shared.key?(:groups) ? shared[:groups] : opts.key?(:groups) ? opts.delete(:groups) : true)
      groups = shared[:groups]
    end
    if opts[:use] then
      use = opts.delete(:use)
    else
      parsed_use = opts.select{|k,v| k.length<2 and /[[:upper:]]/.match(k)} # Parse capital letters from the opts
      if !parsed_use.empty? then
        parsed_use.each do |key,val|
          if (val.is_a? String) then
            n = n.gsub key.to_s, val
            parsed_use.delete(:key)
          end
        end
        opts.except!(*parsed_use.keys)
        use = parsed_use
      end
    end
    dgr_lengths = opts.delete(:lengths) if opts[:lengths]
    control_chars = @@control_chars.clone
    control_chars.except!(*use.keys) if use
    n = lsystem(n,opts.delete(:replace),1,nil)[0] if opts[:replace]
    n = zpreparse(n,opts.delete(:parsekey)) if opts[:parsekey]!=nil
    if opts[:rules] and !shared[:lsystemloop] then
      raise "gen: is not defined" if !opts[:gen]
      gen = opts[:gen] ? opts[:gen] : 1
      n = lsystem(n,opts[:rules],gen,nil)[gen-1]
    end
    defaults = get_default_opts.merge(opts)
    noteLength = defaults[:sleep]
    adsr = defaults.slice(:attack,:decay,:sustain,:release)
    ziff, controlZiff = defaults.clone # Clone defaults to preliminary Hash objects
    current_ziff_keys = []
    n = replace_variable_syntax(n)
    n = replace_random_syntax(n)
    print "Ziffers: "+n
    chars = n.chars # Loop chars
    chars.to_enum.each_with_index do |c, index|
      next_c = chars[index+1]
      dgr = nil
      if skip then
        skip = false # Skip next char and continue
      else
        if !escape && control_chars.key?(c.to_sym) then
          escapeType = control_chars[c.to_sym]
          escape = true
          if control_chars[c.to_sym] == :chord then
            stringFloat+=c
            chars.push(" ") if next_c==nil
          end
        elsif (escape || midi) && ((!quoted && (c==' ' || next_c==nil)) || (quoted && c=="'"))
          stringFloat+=c if next_c==nil && c!=' '
          if escape then
            if stringFloat == nil || stringFloat.length==0 then
              ziff[escapeType] = defaults[escapeType] ? defaults[escapeType] : 1.0 # All defaults to 1.0 if not in default_opts
            elsif escapeType == :eval then
              dgr = eval(stringFloat)
            elsif escapeType == :scale || escapeType == :synth then
              ziff[escapeType] = search_list(escapeType == :scale ? scale_names : synth_names, stringFloat)
            elsif escapeType == :key or escapeType == :value then
              ziff[escapeType] = stringFloat.to_s
            elsif escapeType == :arpeggio then
              ziff[:arpeggio] = zparse stringFloat, key: ziff[:key], scale: ziff[:scale], groups: groups
            elsif escapeType == :chord_invert || escapeType == :channel then
              ziff[escapeType] = stringFloat.to_i
            elsif escapeType == :chord then
              chord_key = ziff[:chord_key] ? ziff[:chord_key] : ziff[:key]
              chord_scale = ziff[:chord_scale] ? ziff[:chord_scale] : ziff[:scale]
              parsed_chord = stringFloat
              if parsed_chord.include?("^") then
                chord_name = parsed_chord.split("^")
                parsed_chord = chord_name[0]
                chord_name = chord_name[1]
                if chord_name.include?("*") then
                  chord_octaves = chord_name.split("*")
                  chord_name = chord_octaves[0]
                  chord_octaves = chord_octaves[1].to_i
                end
              elsif parsed_chord.include?("/") then
                scale_notes = parsed_chord.split("/")
                parsed_chord = scale_notes[0]
                scale_notes = scale_notes[1].to_i
              end
              if chord_name or ziff[:chord_name] then
                chord_name = ziff[:chord_name] if !chord_name
                chordRoot = degree parsed_chord.to_sym, chord_key, chord_scale
                ziff[:notes] = chord chordRoot, chord_name, {num_octaves: (chord_octaves ? chord_octaves : 1)}
              else
                ziff[:notes] = chord_degree parsed_chord.to_sym, chord_key, chord_scale, (scale_notes ? scale_notes : 3)
              end
              ziff[:notes] = chord_invert ziff[:notes], ziff[:chord_invert] if ziff[:chord_invert]
              if sfaddition > 0 then
                ziff[:notes] = ziff[:notes]+sfaddition
              end
              if !chord_octaves  && ziff[:chord_octaves] && ziff[:chord_octaves]>1 then
                octave_notes = []
                1.upto(ziff[:chord_octaves]-1) do |ci|
                  ziff[:notes].each do |n|
                    octave_notes.push(ci*12+n)
                  end
                end
                ziff[:notes]+=octave_notes
              end
            elsif escapeType == :sleep then
              if stringFloat.to_f < 20 or stringFloat =~/[0-9]*\.[0-9]+/ then
                noteLength = stringFloat.to_f
              else
                noteLength = stringFloat.to_f / 1920
              end
            elsif [:release,:sustain,:attack,:decay].include?(escapeType) then
              adsr[escapeType] = stringFloat.to_f
            else
              # ~ and something else?"
              ziff[escapeType] = stringFloat.to_f
            end
          else
            note = stringFloat.to_f # MIDI note
          end
          stringFloat = ""
          escape = false
          quoted = false
        elsif escape && (["=",".","+","-","/","*","^"," ",")","("].include?(c) || c=~/^[a-zA-Z0-9]+$/) then
          stringFloat+=c
        elsif escape && (ziff[:lambda] or ziff[:send])
          stringFloat+=c
        elsif use and use.key?(c.to_sym) then
          use_char = use[c.to_sym]
          raise ":run should be array of hashes" if use[:run] and !use[:run].kind_of?(Array)
          if (use_char.is_a? Proc) then
            ziff[:lambda] = use_char
            current_ziff_keys+=[:lambda,:value]
            escape = true
            escapeType = :value
          elsif (use_char.is_a? Hash) then
            if use_char[:port] or use_char[:channel] then
              ziff[:port] = use_char[:port] if use_char[:port]
              ziff[:channel] = use_char[:channel] if use_char[:channel]
              ziff[:cue] = use_char[:cue] if use_char[:cue]
              current_ziff_keys+=[:port,:channel]
              note = use_char[:note] if use_char[:note]
              ziff[:notes] = use_char[:notes] if use_char[:notes]
            elsif use_char[:sample]
              ziff[:sample_opts] = use_char
              ziff[:sample_opts][:run] = use[:run] if !use_char[:run] and use[:run]
            else # If there are no :note or :sample then just pass the parameters on to the following ziffs
              raise ":run should be array of hashes" if use_char[:run] and !use_char[:run].kind_of?(Array)
              ziff.merge! use_char
            end
            current_ziff_keys+=[:cue] if use_char[:cue]
            current_ziff_keys+=[:lambda] if use_char[:lambda]
          else
            if use_char.is_a? Symbol then
              if respond_to? use_char then
                # If symbol is define function
                ziff[:send] = use_char
                current_ziff_keys+=[:send,:value]
                escape = true
                escapeType = :value
              else
                ziff[:sample_opts] = {sample: use_char}
                ziff[:sample_opts][:run] = use[:run] if use[:run]
              end
            end
            note = use_char if use_char.is_a? Integer
          end
        elsif @@default_durs.key?(c.to_sym) then
          noteLength = @@default_durs[c.to_sym]
        else
          case c
          when '(' then
            sub = []
            subList.push(sub)
          when ')' then
            if subList.length>1
              addSub = subList.pop()
              sub = subList.pop()
              sub.push(addSub)
              subList.push(sub)
            else
              subdivide(subList.pop(),noteLength,adsr)
            end
          when "'" then
            quoted = true
          when 'r' then
            note = :r
          when '/' then
            # Removed fraction sleep syntax!
            if next_c=='/' then
              ziff[:skip]=!ziff[:skip]
            end
          when '!' then
            # Reset node options to defaults
            addition = 0
            slideNext = false
            ziff = ziff.merge(defaults)
            ziff.delete(:run)
          when '.' then
            dot+=1
            dotLength = (2.0-(1.0/(2*dot))) # https://en.wikipedia.org/wiki/Dotted_note
          when /^[0-9TE]+$/ then
            if c == "T" then
              c_int = 10
            elsif c == "E"
              c_int = 11
            else
              c_int = c.to_i
              c_int = c_int - 1 if (@@degree_based or degree_based) and !negative and c_int>0
            end
            if midi && c!="T" && c!="E" then
              stringFloat+=c
            elsif !slideNext and groups and (next_c =~ /[0-9TE#&^_-]/)
              customChord.push(get_note_from_dgr(c_int,(ziff[:chord_key]!=nil ? ziff[:chord_key] : ziff[:key]),ziff[:scale])+sfaddition)
              customChordDegrees.push(c_int)
            elsif !slideNext and groups and customChord.length>0 and !(next_c =~ /[0-9TE#&^_-]/)
              customChord.push(get_note_from_dgr(c_int,(ziff[:chord_key]!=nil ? ziff[:chord_key] : ziff[:key]),ziff[:scale])+sfaddition)
              customChordDegrees.push(c_int)
              ziff[:notes] = customChord
              ziff[:degrees] = customChordDegrees
              customChord=[]
              customChordDegrees=[]
            else
              dgr = c_int # Plain degrees 1234 etc.
            end
          when '?' then
            if escape then
              if escapeType == :pan then
                ziff[:pan] = [1,-1,0].choose
                escapeType = nil
                escape = false
              else
                stringFloat = stringFloat+rrand_i(1,7).to_s
              end
            else
              dgr = rrand_i(1,scale(ziff[:key],ziff[:scale]).length-1)
            end
          when '#' then
            sfaddition += 1
          when 'b' then
            sfaddition -= 1
          when '^' then
            ziff[:pitch] += 12
          when '_' then
            ziff[:pitch] -= 12
          when '-'
            negative=true
          when ':' then
            if noteBuffer.length > 0 then # Loop is ending
              noteClones = noteBuffer.map {|n| n.clone }
              if loopCount<1 then # If : loop
                if (Integer(next_c) rescue false) then
                  notes = notes.concat(noteClones*(next_c.to_i-1)) # Numbered :3 loop
                  skip = true # Skip next
                else
                  notes = notes.concat(noteClones) # Normal : loop
                end
              end
              loopCount = 0
              noteBuffer = []
              loop = false
            else
              loop = true # Loop is starting
            end
          when ";" then
            if noteBuffer.length > 0 then
              loopCount+=1
              notes = notes.concat(noteBuffer) if loopCount>1
            else
              raise "Use of : is mandatory before ;"
            end
          when '@' then # Recursive call from @ to @
            if ds then
              again = zparse(n[/\@(.*?)@/,1], defaults, shared.clone)
              notes = notes.concat(again)
            else
              ds = !ds
            end
          when '*' then # Recursive call from beginning to first *
            if dc then
              notes = notes.concat(zparse(n.split('*')[0], defaults.merge(pitch: ziff[:pitch]), shared.clone))
            else
              dc = !dc
            end
          when '{' then
            escape = true
          when '}',',' then
            customChord.push(get_note_from_dgr(stringFloat.to_i,(ziff[:chord_key]!=nil ? ziff[:chord_key] : ziff[:key]),ziff[:scale])+sfaddition)
            customChordDegrees.push(stringFloat.to_i)
            stringFloat = ""
            if c =='}' then
              ziff[:notes] = customChord
              ziff[:degrees] = customChordDegrees
              customChord=[]
              customChordDegrees=[]
              escape = false
            end
          else
            # all other nonsense
          end
        end
        # If any degree was parsed, parse note and add to hasharray
        if dgr!=nil || note!=0 then

          if dgr!=nil then

            dgr = -(dgr) if negative
            dgr = dgr+ziff[:add] if ziff[:add]
            dgr = dgr+get_real_dgr(ziff[:addmod].to_i, ziff[:key], ziff[:scale]) if ziff[:addmod]

            if ziff[:inverse] then
              if (ziff[:inverse].is_a? Numeric) && dgr!=ziff[:inverse] then
                dgr = -((dgr-ziff[:inverse])-ziff[:inverse])
              elsif (ziff[:inverse].is_a? TrueClass)
                dgr = -(dgr)
              end
            end

            dgr = dgr+ziff[:offset] if ziff[:offset]
            dgr = dgr+get_real_dgr(ziff[:offsetmod],ziff[:key],ziff[:scale]) if ziff[:offsetmod]

            dgr = get_real_dgr(dgr, ziff[:key], ziff[:scale]) if ziff[:real]

            note = get_note_from_dgr(dgr, ziff[:key], ziff[:scale])

          end

          if slideNext then
            controlZiff[:degree] = dgr
            controlZiff[:note] = note
            controlZiff[:sleep] = noteLength*dotLength
            controlZiff[:pitch] = controlZiff[:pitch]+sfaddition
            controlZiff[:pitch_slide] = defaults[:pitch_slide] ? defaults[:pitch_slide] : 0.2
            if sfaddition!=0 then
              controlZiff[:pitch] = controlZiff[:pitch]-sfaddition
              sfaddition=0
            end
            controlBuffer.push(controlZiff.clone)
            if next_c == nil || next_c == ' ' then
              slideNext = false # Slide ends
              ziff[:control] = controlBuffer
              # TODO: Change release to calculated value from all control ziffs
              ziff[:release] = (ziff[:sleep]==0 ? 1 : ziff[:sleep]) * (ziff[:control].length+1)
              noteBuffer.push(ziff.clone) if loop && loopCount<1 # : buffer
              ziff = ziff.clone # Clone opts to next object
              ziff.delete(:control)
              controlBuffer = []
            end
          else

            if escapeType==:note_slide then
              slideNext=true # Slide starts
              escapeType=nil
              controlZiff = ziff.clone # Create slidenode & delete nonmodulatable
              controlZiff = controlZiff.except(:attack,:release,:sustain,:decay)
            end

            ziff[:degree] = dgr
            ziff[:note] = note

            if dgr_lengths then # Custom map for degree lengths: { 1:0.5, 2:0.25 }
              dgr_sleep = dgr_lengths[dgr] # Try -1 or 9 etc. otherwise try with real degrees
              dgr_sleep = dgr_lengths[get_real_dgr(dgr,ziff[:key], ziff[:scale])] if !dgr_sleep
            end

            if !escape and groups and (use and next_c and use.key?(next_c.to_sym)) then
              # If parsing drum notation with groups: B K BH K etc.
              ziff[:sleep] = 0
            else
              if dgr_sleep then
                ziff[:sleep] = (dgr_sleep.is_a?(String) ? @@default_durs[dgr_sleep.to_sym] : dgr_sleep)*dotLength
              else
                ziff[:sleep] = noteLength*dotLength
              end
            end
            set_ADSR(ziff,adsr)
            ziff[:pitch] = ziff[:pitch]+sfaddition
            noteBuffer.push(ziff) if !slideNext && loop && loopCount<1 # : buffer
            notes.push(ziff)
            sub.push(ziff) if ziff[:sleep]>0 and subList.length>0
            # Next ziff
            if !slideNext then
              ziff = ziff.clone
              ziff.delete(:degree)
              ziff.delete(:note)
              ziff.except!(*current_ziff_keys)
              if sfaddition!=0 then
                ziff[:pitch] = ziff[:pitch]-sfaddition
                sfaddition=0
              end
            end
          end
          dot = 0
          negative=false
          dotLength = 1.0
          note = 0
          current_ziff_keys = []
        elsif ziff[:notes]
          chordZiff = ziff.clone
          chordZiff[:sleep] = defaults[:chord_sleep] ? defaults[:chord_sleep] : noteLength
          set_ADSR(chordZiff,adsr)
          # TODO: Handle chord adsr with separate opts?
          chordZiff[:release] = defaults[:chord_release] if defaults[:chord_release]
          notes.push(chordZiff)
          noteBuffer.push(chordZiff) if loop && loopCount<1 # : buffer
          sub.push(chordZiff) if chordZiff[:sleep]>0 and subList.length>0
          ziff.delete(:notes)
          ziff.delete(:degrees)
          ziff.except!(*current_ziff_keys)
          current_ziff_keys = []
          sfaddition=0
        elsif ziff[:sample_opts]
          sample_opts = ziff.delete(:sample_opts)
          sampleZiff = ziff.clone
          sampleZiff.merge!(sample_opts)
          sampleZiff[:sleep] = (groups and next_c and use.key?(next_c.to_sym)) ?  0 : (noteLength*dotLength) if !sample_opts[:sleep]
          notes.push(sampleZiff)
          noteBuffer.push(sampleZiff) if loop && loopCount<1 # : buffer
          sub.push(sampleZiff) if sampleZiff[:sleep]>0 and subList.length>0
        elsif !escape and (ziff[:lambda] or ziff[:send])
          callZiff = ziff.clone
          callZiff[:sleep] = noteLength*dotLength
          notes.push(callZiff)
          noteBuffer.push(callZiff) if loop && loopCount<1 # : buffer
          sub.push(callZiff) if callZiff[:sleep]>0 and subList.length>0
          ziff.except!(*current_ziff_keys)
          current_ziff_keys = []
        end
        # Continues loop
      end
    end
    notes
  end

  # Reverses degrees but keeps the chords in place
  # Example: "i 1234 v 2341" -> "i 1432 v 4321"
  def zreverse(arr,with_chords=false)
    i=0
    x=arr.length-1
    until x<=i do
      if !arr[i][:notes] or with_chords then
        if !arr[x][:notes] or with_chords then
          arr[i], arr[x] = arr[x], arr[i]
          i+=1
          x-=1
        else
          x-=1
        end
      else
        i+=1
      end
    end
    arr
  end

  # Sets ADSR envelope for given note
  def set_ADSR(ziff,adsr)
    note_length = (ziff[:sleep]==0 ? 1 : ziff[:sleep]*1.5)
    ziff[:attack] = adsr[:attack] * note_length if adsr[:attack]!=nil
    ziff[:decay] = adsr[:decay] * note_length if adsr[:decay]!=nil
    ziff[:sustain] = adsr[:sustain] * note_length if adsr[:sustain]!=nil
    ziff[:release] = adsr[:release] * note_length if adsr[:release]!=nil
  end

  # Divides sleeps for each element in array and subarrays
  def subdivide(subs,divSleep,adsr)
    subs.each do |z|
      if z.kind_of? Array
        subdivide(z,divSleep/subs.length,adsr)
      else
        z[:sleep]=divSleep/subs.length if z[:sleep] and z[:sleep]>0
        set_ADSR(z,adsr) if adsr and z[:note]
      end
    end
  end

  # Scales degrees to scale, for example -1=7 and 8=1
  def get_real_dgr(dgr,zkey,zscale)
    scaleLength = scale(zkey,zscale).length-1
    return dgr<0 ? (scaleLength+1)-(dgr.abs%scaleLength) : dgr%scaleLength
  end

  # Gets note from degree. Degree can also be negative or overflow to next octave
  def get_note_from_dgr(dgr, zkey, zscale)
    dgr+=1 if dgr>=0 # 0 -> 1, etc.
    scaleLength = scale(zkey,zscale).length-1
    if dgr>=scaleLength || dgr<0 then
      oct = (dgr-1)/scaleLength*12
      dgr = dgr<0 ? (scaleLength+1)-(dgr.abs%scaleLength) : dgr%scaleLength
      return degree(dgr==0 ? scaleLength : dgr,zkey,zscale)+oct
    end
    return degree(dgr,zkey,zscale)
  end

  def search_list(arr,query)
    result = (Float(query) != nil rescue false) ? arr[query.to_i] : arr.find { |e| e.match( /\A#{Regexp.quote(query)}/)}
    (result == nil ? query : result)
  end

  def zparams(hash, name)
    hash.map{|x| x[name]}
  end

  def clean(ziff)
    ziff.except(:send, :lambda, :synth, :cue,:rules,:eval,:gen,:arpeggio,:key,:scale,:chord_sleep,:chord_release,:chord_invert,:rate_based,:skip,:midi,:control,:degrees,:run,:sample)
  end

  def play_midi_out(md, opts)
    midi md, opts
  end

  def detune_notes(ziff,detune)
    if ziff[:notes] then
      notes = ziff[:notes].to_a
      notes.each_with_index do |n,i|
        notes[i] = hz_to_midi(midi_to_hz(n)+detune)
      end
      ziff[:notes] = notes.ring
    elsif ziff[:note]
      ziff[:note] = hz_to_midi(midi_to_hz(ziff[:note])+detune)
    end
  end

  def play_ziff(ziff,defaults={})
    cue ziff[:cue] if ziff[:cue]
    detune_notes ziff, defaults[:detune] if defaults[:detune]
    if ziff[:send] then
      send(ziff[:send],ziff)
    elsif ziff[:skip] then
      print "Skipping note"
    elsif ziff[:notes] then
      if ziff[:arpeggio] then
        arp_opts = ziff.except(:key,:scale,:note,:notes,:arpeggio,:degree,:sleep)
        ziff[:arpeggio].each do |cn|
          if cn[:degrees] then
            arp_chord = cn[:degrees].map{|d| ziff[:notes][d]}
            arp_notes = {notes: arp_chord}
          else
            arp_notes = {note: ziff[:notes][cn[:degree]]}
          end
          arp_opts = cn.merge(arp_notes).except(:degrees)
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
            synth ziff[:chord_synth]!=nil ? ziff[:chord_synth] : current_synth, arp_opts
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
          synth ziff[:chord_synth]!=nil ? ziff[:chord_synth] : ziff[:synth] ? ziff[:synth] : current_synth, clean(ziff)
        end
      end
    elsif ziff[:port] then
      sustain = ziff[:sustain]!=nil ? ziff[:sustain] : ziff[:release]
      play_midi_out(ziff[:note]+ziff[:pitch], ziff.slice(:port,:channel,:vel,:vel_f).merge({sustain: sustain}))
    else
      slide = ziff.delete(:control)
      if ziff[:sample]!=nil then
        if defaults[:rate_based] && ziff[:note]!=nil then
          ziff[:rate] = pitch_to_ratio(ziff[:note]-note(ziff[:key]))
        elsif ziff[:degree]!=nil then
          ziff[:pitch] = (scale 1, ziff[:scale], num_octaves: 2)[ziff[:degree]]+ziff[:pitch]-0.999
        end
        if ziff[:cut] then
          ziff[:finish] = [0.0,(ziff[:sleep]/(sample_duration (ziff[:sample_dir] ? [ziff[:sample_dir], ziff[:sample]] : ziff[:sample])))*ziff[:cut],1.0].sort[1]
          ziff[:finish]=ziff[:finish]+ziff[:start] if ziff[:start]
        end
        c = sample (ziff[:sample_dir] ? [ziff[:sample_dir], ziff[:sample]] : ziff[:sample]), clean(ziff)
      elsif ziff[:note] or ziff[:notes]
        if ziff[:synth] then
          c = synth ziff[:synth], clean(ziff)
        else
          c = play clean(ziff)
        end
      end
      if slide != nil then
        sleep ziff[:sleep]*(ziff[:note_slide] ? ziff[:note_slide] : 0.5)
        slide.each do |cziff|
          cziff[:pitch] = (scale 1, cziff[:scale])[cziff[:degree]]+cziff[:pitch]-0.999 if cziff[:sample]!=nil && cziff[:degree]!=nil
          control c, clean(cziff)
          sleep cziff[:sleep]
        end
      end
    end
  end

  def zplay(melody,opts={},defaults={})
    # Extract common options to defaults
    parseCommonOpts(opts)
    defaults = defaults.merge(opts.extract!(*@@default_keys))
    opts = get_default_opts.merge(opts)
    defaults[:preparsed] = true if !defaults[:parsed] and melody.is_a?(Array) and melody[0].is_a?(Hash)
    if melody.is_a? Enumerator then
      enum = melody
      melody = enum.next
      melody = normalize_melody(melody, opts, defaults) if !defaults[:parsed] and !defaults[:preparsed]
    elsif defaults[:name] and $zloop_states[defaults[:name]][:enumeration] then
      melody = $zloop_states[defaults[:name]][:enumeration].next
    elsif defaults[:store] and defaults[:name] and $zloop_states[defaults[:name]][:parsed_ziff]
      melody = $zloop_states[defaults[:name]][:parsed_ziff]
    else
      melody = normalize_melody(melody, opts, defaults) if !defaults[:parsed] and !defaults[:preparsed]
      if has_combinatorics(defaults)
        enum = parse_combinatorics(melody,defaults)
        melody = enum.next
      end
    end
    loop_i = defaults[:name] ? $zloop_states[defaults[:name]][:loop_i] : 0
    loop do
      melody = apply_array_transformations(melody, opts, defaults, loop_i) if !defaults[:transform_single]
      if !opts[:port] and defaults[:run] then
        block_with_effects defaults[:run].clone do
          zplayer(melody,opts,defaults,loop_i)
        end
      else
        zplayer(melody,opts,defaults,loop_i)
      end
      print "Cycle index: "+loop_i.to_s if @@debug
      break if !enum
      melody = enum.next
      loop_i = loop_i+1
      melody = normalize_melody(melody, opts, defaults) if !defaults[:parsed] and !defaults[:preparsed] if melody.is_a? String or melody.is_a? Numeric
    end
  end

  def zplayer(melody,opts={},defaults={},loop_i=0)
    if melody.length==0 then
      $zloop_states.delete(defaults[:name]) if defaults[:name]
      stop
    end
    tick_reset(:adjust) if defaults.delete(:readjust)
    melody.each_with_index do |ziff,index|
      ziff = apply_transformation(ziff, defaults, loop_i, index, melody.length)
      if ziff[:lambda] then
        ziff[:lambda].() if ziff[:lambda].arity == 0
        ziff[:lambda].(ziff) if ziff[:lambda].arity == 1
        ziff[:lambda].(ziff,index) if ziff[:lambda].arity == 2
        ziff[:lambda].(ziff,index,loop_i) if ziff[:lambda].arity == 3
        ziff[:lambda].(ziff,index,loop_i,melody.length) if ziff[:lambda].arity == 4
      end
      ziff = opts.merge(merge_rate(ziff, defaults)) if defaults[:preparsed]
      if defaults[:adjust] then
        t_index = tick(:adjust)
        # If adjust is lambda
        if (defaults[:adjust].is_a? Proc) then
          defaults[:adjust].() if defaults[:adjust].arity == 0
          defaults[:adjust].(ziff) if defaults[:adjust].arity == 1
          defaults[:adjust].(ziff,index) if defaults[:adjust].arity == 2
          defaults[:adjust].(ziff,index,loop_i) if defaults[:adjust].arity == 3
          defaults[:adjust].(ziff,index,loop_i,melody.length) if defaults[:adjust].arity == 4
        else
          defaults[:adjust].each do |key,val|
            # If adjust value is lambda
            if val.is_a? Proc then
              ziff[key] = val.() if val.arity == 0
              ziff[key] = val.(ziff[key]) if val.arity == 1
              ziff[key] = val.(ziff[key], index) if val.arity == 2
              ziff[key] = val.(ziff[key], index, loop_i) if val.arity == 3
              ziff[key] = val.(ziff[key], index, loop_i, melody.length) if val.arity == 4
            else
              # If adjust is ring or array
              #TODO: Not optimal solution. This overwrites all following changes on the fly.
              ziff[key] = val[t_index] ? val[t_index] : val[val.length-1]
            end
          end
        end
      end
      if ziff[:run] then
        block_with_effects ziff[:run].clone do
          play_ziff(ziff,defaults)
        end
      else
        play_ziff(ziff,defaults)
      end
      sleep ziff[:sleep] if !ziff[:skip] and !(ziff[:notes] and ziff[:arpeggio])
    end
    # Save loop state
    if defaults[:store] and defaults[:name] then
      $zloop_states[defaults[:name]][:parsed_ziff] = melody
      if @@debug then
        print "Stored:"
        print zparams melody, :degree
      end
    end
  end

  def normalize_melody(melody, opts, defaults)
    if melody.is_a?(String)
      return zparse(melody,opts,defaults)
    elsif melody.is_a?(Numeric) # zplay 1 OR zmidi 85
      if defaults[:midi] then
        opts[:note] = melody
      else
        opts[:note] = get_note_from_dgr(melody, opts[:key], opts[:scale])
      end
      set_ADSR(opts,@@default_opts.slice(:attack,:decay,:sustain,:release))
      return [opts]
    elsif melody.is_a?(Array)
      return zarray(melody,opts)
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

  # Sets common attributes for zloop and zplay
  def parseCommonOpts(opts)
    @@rmotive_lengths = (expand_repeat_syntax(opts[:rhythm]).split("").reduce([]) {|acc,c| (@@default_durs.keys.include? c.to_sym) ? acc << @@default_durs[c.to_sym] : acc}).ring if opts[:rhythm] and (opts[:rhythm].is_a? String)
  end

  def zloop(name, ziff, opts={}, defaults={})
    parseCommonOpts(opts)
    defaults[:name] = name
    defaults = defaults.merge(opts.extract!(*@@default_keys))
    clean_loop_states # Clean unused loop states
    $zloop_states.delete(name) if opts.delete(:reset)
    if opts[:adjust]
      defaults[:adjust] = opts.delete(:adjust)
      defaults[:readjust] = true if not (opts.delete(:readjust)==false)
    end
    raise "First parameter should be loop name as a symbol!" if !name.is_a?(Symbol)
    raise "Third parameter should be options as hash object!" if !opts.kind_of?(Hash)
    if !$zloop_states[name] then # If first time
      $zloop_states[name] = {}
      $zloop_states[name][:loop_i] = 0
    end
    $zloop_states[name][:cycle] = opts.delete(:cycle) if opts[:cycle]
    create_loop_opts(opts,$zloop_states[name])
    defaults.merge!(opts.extract!(:wait))
    if opts[:phase] then
      defaults[:phase] = opts.delete(:phase)
      defaults[:phase] = defaults[:phase].to_a if (defaults[:phase].is_a? SonicPi::Core::RingVector)
    end
    if ziff.is_a?(Array) && ziff[0].is_a?(Hash) then
      defaults[:preparsed] = true
    elsif (opts[:parse] or (has_combinatorics(opts)) and !$zloop_states[name][:enumeration]) and (ziff.is_a?(String) and !ziff.start_with? "//") and !opts[:seed]
      parsed_ziff = normalize_melody ziff, opts.except(*@@default_keys), defaults
      enumeration = parse_combinatorics parsed_ziff, opts
      if enumeration then
        $zloop_states[name][:enumeration] = enumeration.cycle
      else
        parsed_ziff = parse_modifications parsed_ziff, opts
      end
      defaults[:parsed] = true
    end
    live_loop name, opts.slice(:init,:auto_cue,:delay,:sync,:sync_bpm,:seed) do

      eval_loop_opts(opts,$zloop_states[name])
      sync defaults[:wait] if defaults[:wait]

      if opts[:phase] or defaults[:phase] then
        defaults[:phase] = opts.delete(:phase) if opts[:phase]
        phase = defaults[:phase].is_a?(Array) ? defaults[:phase][$zloop_states[name][:loop_i] % defaults[:phase].length] : defaults[:phase]
        sleep phase
      end

      if opts[:stop] and ((opts[:stop].is_a? Numeric) and $zloop_states[name][:loop_i]>=opts[:stop]) or (opts[:stop].is_a? TrueClass) or (ziff.is_a?(String) and ziff.start_with? "//") then
        $zloop_states.delete(name)
        stop
      end

      if $zloop_states[name][:cycle] then
        loop_opts = opts.clone
        cycle_array = ($zloop_states[name][:cycle].is_a? Array) ? $zloop_states[name][:cycle] : [$zloop_states[name][:cycle]]
        cycle_array.each do |value|
          raise "Expected :mod in :cycle object!" if !value[:mod]
          if value[:first] or value[:last] or (value[:from] and value[:to]) then
            mod_cycles = ($zloop_states[name][:loop_i]+1) % value[:mod]
            mod_cycles = value[:mod] if mod_cycles == 0
            if value[:from] and value[:to] and mod_cycles >= value[:from] and mod_cycles <= value[:to] then
              loop_opts = get_loop_opts(value.except(:mod,:first,:last,:from,:to),loop_opts,$zloop_states[name][:loop_i])
            elsif (value[:first] and mod_cycles <= value[:first]) or (value[:last] and mod_cycles>(value[:mod]-value[:last])) then
              loop_opts = get_loop_opts(value.except(:mod,:first,:last,:from,:to),loop_opts,$zloop_states[name][:loop_i])
            end
          elsif ($zloop_states[name][:loop_i]+1) % value[:mod] == 0 then
            loop_opts = get_loop_opts(value.except(:mod),loop_opts,$zloop_states[name][:loop_i])
          end
        end
      end

      if defaults[:preparsed] then
        zplay ziff, opts, defaults
      elsif parsed_ziff
        zplay parsed_ziff, opts.slice(:run,:detune), defaults
      else
        if opts[:rules] and !opts[:gen] then
          defaults[:lsystemloop] = true
          $zloop_states[name][:ziff] = ziff if !$zloop_states[name][:ziff]
          $zloop_states[name][:ziff] = (lsystem($zloop_states[name][:ziff], opts[:rules], 1, $zloop_states[name][:loop_i]))[0]
          zplay $zloop_states[name][:ziff], opts, defaults
        else
          zplay ziff, loop_opts ? loop_opts : opts, defaults
        end
      end
      $zloop_states[name][:loop_i] += 1
    end
  end

  def has_combinatorics(opts)
    return (opts[:permutation] or opts[:iteration] or opts[:combination])
  end

  # Parses enum or returns nil
  def parse_combinatorics(parsed_ziff, opts)
    iteration = opts.delete(:iteration)
    combination = opts.delete(:combination)
    permutation = opts.delete(:permutation)
    repeated = opts.delete(:repeated)
    transposed = opts.delete(:transpose)
    if permutation or combination or iteration then
      if permutation then
        enumeration = repeated ? parsed_ziff.repeated_permutation(permutation) : parsed_ziff.permutation(permutation)
      elsif combination
        enumeration = repeated ? parsed_ziff.repeated_combination(combination) : parsed_ziff.combination(combination)
      elsif iteration
        enumeration = parsed_ziff.each_cons(iteration)
      end
      print "Enumeration size: "+enumeration.size.to_s
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

  def zspread x, y, ziff, offbeat="r", rotate=0, join=" "
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

  def lsystem(ax,rules,gen,loopGen)
    gen.times.collect.with_index do |i|
      i = loopGen if loopGen # If lsystem is used in loop instead of gens
      ax = rules.each_with_object(ax.dup) do |(k,v),s|
        v = v[i] if (v.is_a? Array or v.is_a? SonicPi::Core::RingVector) # [nil,"1"].ring -> every other
        if v then
          s.gsub!(/{{.*?}}|(#{k.is_a?(String) ? Regexp.escape(k) : k})/) do |m|
            g = Regexp.last_match.captures
            if g[0] and !g[0].empty? then # If there is at least one match
              if v.is_a? Proc then
                if v.arity == 1 then
                  rep = v.(i).to_s
                elsif v.arity == 2
                  rep = v.(i,g).to_s
                else
                  rep = v.().to_s
                end
              else # If not using lambda
                rep = replace_random_syntax(replace_variable_syntax(v))
                rep = g.length>1 ? rep.gsub(/\$([1-9])/) {g[Regexp.last_match[1].to_i]} : rep.gsub("$",m)
                rep = rep.include?("'") ? rep.gsub(/'(.*?)'/) {eval($1)} : rep
              end
              "{{#{rep}}}" # Escape
            else
              m # If escaped
            end
          end
        end
      end
      ax = ax.gsub(/{{(.*?)}}/) {$1}
    end
  end

  def zpreparse(n,key)
    noteList = ["c","d","e","f","g","a","b"]
    key = (key.is_a? Symbol) ? key.to_s.chars[0].downcase : key.chars[0].downcase
    ind = noteList.index(key)
    noteList = noteList[ind...noteList.length]+noteList[0...ind]
    n.chars.map { |c| noteList.index(c)!=nil ? noteList.index(c) : c  }.join('')
  end

  def zarray(arr, opts=get_default_opts)
    zmel=[]
    arr.each do |item|
      if item.is_a? Array then
        zmel.push array_to_hash(item,opts)
      elsif item.is_a? Numeric then
        if item!=0 then
          opts[:note] = get_note_from_dgr(item, opts[:key], opts[:scale])
          zmel.push(opts.clone)
        end
      end
    end
    zmel
  end

  def array_to_hash(obj,opts=get_default_opts)
    defObj = [0,opts[:sleep],opts[:key],opts[:scale],opts[:release]]
    arrayOpts = [:note,:sleep,:key,:scale,:release]
    obj.each_with_index { |item,index| defObj[index] = item }
    defObj[0] = get_note_from_dgr(defObj[0], defObj[2], defObj[3])
    opts.merge(Hash[arrayOpts.zip(defObj)])
  end

  def zbeats(arr)
    zparams(arr,:sleep).inject(0){|sum,x| sum+x }
  end

  # TRANSFORMATIONS

  def reflect_collection(part_a)
    part_b = part_a.reverse
    if part_b[0].is_a?(Array) then
      part_b = part_b.map { |arr| arr.reverse }
      part_b[0].shift
      part_b.delete_at(0) if part_b[0].empty?
      part_b[part_b.length-1].pop
      part_b.delete_at(part_b.length-1) if part_b[part_b.length-1].empty?
    else
      part_b.shift
      part_b.pop
    end
    return (part_a+part_b)
  end

  def apply_array_transformations(melody, opts, defaults, loop_i=0)
    defaults.each do |key,val|
      if val.is_a? Proc then
        val = val.() if val.arity == 0
        val = val.(loop_i) if val.arity == 1
      end
      case key
      when :retrograde then
        return zretrograde melody, val
      when :swap then
        return swap melody, *val
      when :rotate then
        return melody.rotate(val)
      when :division then
        return melody.group_by {|z| z[:degree].to_i % val}.values.flatten
      when :mirror then
        return melody+melody.reverse
      when :reverse then
        return melody.reverse
      when :reflect then
        return reflect_collection melody
      when :subset then
        return (val.is_a? Numeric) ? [melody[val]] : melody[val]
      when :inject then
        return melody.inject(val.is_a?(Array) ? val : (normalize_melody val, opts, defaults)){|a,j| a.flat_map{|n| [n,augment(j, n)]}}
      when :zip then
        return melody.zip(val.is_a?(Array) ? val : (normalize_melody val, opts, defaults)).flatten
      when :append then
        return melody + (val.is_a?(Array) ? val : (normalize_melody val, opts, defaults))
      when :prepend then
        return (val.is_a?(Array) ? val : (normalize_melody val, opts, defaults)) + melody
      when :shuffle then
        return val.is_a? TrueClass ? melody.shuffle : (melody[val] = val[val].shuffle)
      when :drop then
        melody.slice!(val)
        return melody
      when :slice then
        return melody.slice(val)
      when :pop then
        if val.is_a? TrueClass
          melody.pop
        else
          melody.pop(val)
        end
        return melody
      when :shift
        if val.is_a? TrueClass
          melody.shift
        else
          melody.shift(val)
        end
        return melody
      when :pick
        return melody.pick(val)
      when :stretch
        return (stretch melody, val).to_a
      when :order_transform
        return send(val, melody, loop_i)
      end
    end
    return melody
  end

  def apply_transformation(ziff, defaults, loop_i=0, note_i=0, melody_size=1)
    defaults.each do |key,val|
      if val.is_a? Proc then
        val = val.() if val.arity == 0
        val = val.(loop_i) if val.arity == 1
      end
      case key
      when :augment
        return augment ziff, val
      when :flex
        return flex ziff, val
      when :silence
        return silence ziff, val
      when :harmonize
        return harmonize ziff, defaults
      when :rhythm
        return zrhythm_motive ziff, val, (loop_i>0 ? (melody_size*loop_i+note_i) : note_i)
      when :object_transform
        return send(val,ziff,loop_i,note_i,melody_size)
      end
    end
    return ziff
  end

  def zrhythm_motive(ziff, rmotive, mot_i)
    print mot_i
    if @@rmotive_lengths then
      ziff[:sleep] = @@rmotive_lengths[mot_i]
    elsif rmotive.is_a? Array then
      ziff[:sleep] = rmotive.ring[mot_i]
    elsif rmotive.is_a? SonicPi::Core::RingVector then
      ziff[:sleep] = rmotive[mot_i]
    end
    return ziff
  end

  def zretrograde(notes,retrograde,chords=false)
    if retrograde.is_a?(Array) then # Retrograding subarray
      retrograde[1] = notes.length if retrograde[1]>notes.length or retrograde[1]<=retrograde[0]
      retrograde[0] = 0 if retrograde[0]<0
      rev_notes = []
      rev_notes += notes[0,retrograde[0]] if retrograde[0]>0
      rev_notes += zreverse notes[retrograde[0]..retrograde[1]], chords
      rev_notes += (retrograde[1]<notes.length) ? notes[retrograde[1]+1..notes.length] : [notes[retrograde[1]]] if retrograde[1]+1<notes.length
      return rev_notes
    elsif retrograde.is_a?(Numeric) # Retrograding partial arrays splitted to equal parts
      return notes.each_slice(retrograde).map{|part| zreverse part, chords }.flatten
    elsif retrograde.is_a?(TrueClass)
      return zreverse notes, chords # Normal retrograde
    else
      return notes
    end
  end

  def swap(melody,n,x=1)
    n = n % melody.length if n>=melody.length
    n2 = (n+x)>=melody.length ? ((n+x) % melody.length) : n+x
    melody[n], melody[n2] = melody[n2], melody[n]
    melody
  end

  def flex(ziff,ratio)
    if ziff[:sleep] then
      ziff[:sleep] = ziff[:sleep] + ziff[:sleep]*ratio
      set_ADSR(ziff,@@default_opts.slice(:attack,:decay,:sustain,:release))
    end
    return ziff
  end

  def compound(ziff,interval)
    if interval>0 or interval<0 then
      if ziff[:note] then
        ziff[:notes] = []
        ziff[:notes].push ziff[:note]
        new_note = get_note_from_dgr ziff[:degree]+(interval-1), ziff[:key], ziff[:scale]
        scale_length = scale(ziff[:key],ziff[:scale]).length-1
        ziff[:notes].push new_note + scale_length
        ziff.delete(:note)
      end
    end
    return ziff
  end

  def silence(ziff,degrees)
    if ziff[:note] and ziff[:degree] then
      if ((degrees.is_a? Numeric) and degrees==ziff[:degree]) or ((degrees.is_a? Array) and (degrees.include? ziff[:degree]))  then
        ziff[:note] = :r
      end
    end
    return ziff
  end

  def get_interval_note(degree, interval, compound, key, scale)
    add_to = 0
    if (interval.is_a? String) then
      if (interval.include? "#")
        interval = interval.sub "#",""
        add_to += 1
      elsif (interval.include? "b")
        interval = interval.sub "b",""
        add_to -= 1
      end
    end
    interval = interval.to_i
    interval = interval==0 ? interval+compound : interval>0 ? interval-1+compound : interval+1-compound
    return (get_note_from_dgr (degree+interval+compound), key, scale)+add_to
  end

  def harmonize(ziff,opts)
    if opts[:harmonize] then
      if ziff[:note] and ziff[:degree] then
        degrees = opts[:harmonize]
        ziff[:notes] = []
        ziff[:notes].push ziff[:note]
        compound = 0
        if opts[:compound] then
          scale_length = scale(ziff[:key],ziff[:scale]).length-1
          compound = scale_length*opts[:compound]
        end
        if degrees.is_a? Hash then
          degree_intervals = degrees[ziff[:degree]]
          if degree_intervals then
            if degree_intervals.is_a? Array then
              degree_intervals.each do |interval|
                ziff[:notes].push get_interval_note ziff[:degree], interval, compound, ziff[:key], ziff[:scale]
              end
            else
              ziff[:notes].push get_interval_note ziff[:degree], degree_intervals, compound, ziff[:key], ziff[:scale]
            end
          end
        elsif degrees.is_a? Array
          degrees.each do |interval|
            ziff[:notes].push get_interval_note ziff[:degree], interval, compound, ziff[:key], ziff[:scale]
          end
        else
          ziff[:notes].push get_interval_note ziff[:degree], degrees, compound, ziff[:key], ziff[:scale]
        end
        ziff[:notes] = ziff[:notes].ring
        ziff[:notes] = chord_invert ziff[:notes], ziff[:chord_invert] if ziff[:chord_invert]
        ziff.delete(:note)
      end
    end
    return ziff
  end

  def get_interval_note(degree, interval, compound, key, scale)
    add_to = 0
    if (interval.is_a? String) then
      if (interval.include? "#")
        interval = interval.sub "#",""
        add_to += 1
      elsif (interval.include? "b")
        interval = interval.sub "b",""
        add_to -= 1
      end
    end
    interval = interval.to_i
    interval = interval==0 ? interval+compound : interval>0 ? interval-1+compound : interval+1-compound
    return (get_note_from_dgr (degree+interval), key, scale)+add_to
  end

  def augment(ziff,additions)
    if ziff[:note] and ziff[:degree] then
      if additions[:degree] then
        interval = additions[:degree]
      else
        interval = additions[ziff[:degree]]
      end
      interval = interval.() if (interval.is_a? Proc)
      ziff[:note] = get_interval_note ziff[:degree], interval, 0, ziff[:key], ziff[:scale]
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
