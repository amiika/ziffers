def defaultDurs
  durs = {'m': 8.0, 'l': 4.0, 'd': 2.0, 'w': 1.0, 'h': 0.5, 'q': 0.25, 'e': 0.125, 's': 0.0625, 't': 0.03125,'f': 0.015625, 'z': 0.0 }
end

def chordDefaults
  defaults = { :chordSleep => 0, :chordRelease => 1, :chordInvert => 0, :sleep => 0 }
end

def defaultSampleOpts
  defaultSampleOpts = { :key => :c, :scale => :major, :sample => :ambi_piano, :rate => 1, :scale => :major, :pan => 0, :release => 0.0 }
end

def defaultOpts
  defaultOpts = {
    :key => :c,
    :scale => :major,
    :release => 1,
    :sleep => 0.25,
    :pitch => 0.0,
    :amp => 1,
    :pan => 0,
    :amp_step => 0.5,
    :note_slide => 0.5,
    :control => nil,
    :skip => false,
    :pitch_slide => 0.25
  }
  defaultOpts.merge(Hash[current_synth_defaults.to_a])
end

def controlChars
  controlChars = {
    'A': :amp,
    'E': :env_curve,
    'C': :attack,
    'P': :pan,
    'D': :decay,
    'S': :sustain,
    'R': :release,
    'Z': :sleep, #Zzz
    'X': :chordSleep,
    'T': :pitch, # Tuning
    'K': :key,
    '~': :note_slide,
    '^': :chord_name,
    'i': :chord,
    'v': :chord,
    '%': :chordInvert
  }
end

def getScaleDegrees(zkey,zscale)
  scaleDegrees = Array.new(scale(zkey,zscale).length){ |i| (i+1) }.ring
end

def replaceRandomSyntax(n) # Replace random values inside [] and ()
  cArr = n.scan(/\[.*?\]/)
  cArr.each do |s|
    n = n.sub(s,s[1,s.length-2].split(",").choose)
  end
  rArr = n.scan(/\(.*?\)/)
  rArr.each do |s|
    revl = s[1,s.length-2].split(",")
    if revl.length > 2 then raise 'Too many parameters' end
    if (Integer(revl[0]) rescue false) then # If int then
      n = n.sub(s,(rrand_i revl[0].to_i, revl[1].to_i).to_s)
    else
      n = n.sub(s,(rrand revl[0].to_f, revl[1].to_f).to_s)
    end
  end
  n
end

def zparse(n,opts={},shared={})
  notes, noteBuffer, controlBuffer = Array.new(3){ [] }
  loop, dc, ds, escape, skip, slideNext = false, false, false, false, false, false
  stringFloat = ""
  noteLength, dotLength = 0.25, 1.0
  sfaddition, dot, loopCount, note = 0, 0, 0, 0, 0
  escapeType = nil
  midi = shared[:midi] ? true : false
  defaults = defaultOpts.merge(opts)
  ziff, controlZiff = defaults.clone # Clone defaults to preliminary Hash objects
  n = replaceRandomSyntax(n)
  chars = n.chars # Loop chars
  chars.to_enum.each_with_index do |c, index|
    next_c = chars[index+1]
    dgr = nil
    if skip then
      skip = false # Skip next char and continue
    else
      if !escape && controlChars.key?(c.to_sym)
        escape = true
        escapeType = controlChars[c.to_sym]
        if controlChars[c.to_sym] == :chord
          stringFloat+=c
          chars.push(" ") if next_c==nil
        end
      elsif (escape || midi) && (c==' ' || next_c==nil)
        stringFloat+=c if next_c==nil && c!=' '
        if escape then
          if stringFloat == nil || stringFloat.length==0 then
            ziff[escapeType] = defaults.fetch(escapeType)
          elsif escapeType == :scale then
            ziff[:scale] = searchList(scale_names, stringFloat)
          elsif escapeType == :synth then
            ziff[:synth] = searchList(synth_names, stringFloat)
          elsif escapeType == :key then
            ziff[:key] = stringFloat.to_s
          elsif escapeType == :chordInvert then
            ziff[:chordInvert] = stringFloat.to_i
          elsif escapeType == :chord then
            chordSets = chordDefaults.merge(ziff.clone)
            parsedChord = stringFloat.split("^")
            if parsedChord.length>1 then
              chordRoot = degree parsedChord[0].to_sym, ziff[:key], ziff[:scale]
              ziff[:chord] = chord_invert chord(chordRoot, parsedChord[1]), chordSets[:chordInvert]
            else
              ziff[:chord] = chord_invert chord_degree(parsedChord[0].to_sym,ziff[:key],ziff[:scale],3), chordSets[:chordInvert]
            end
          elsif escapeType == :sleep then
            noteLength = stringFloat.to_f
            ziff[:sleep] = noteLength
          elsif escapeType == :release then
            defaults[:release] = stringFloat.to_f
          else
            # ~ and something else?
            ziff[escapeType] = stringFloat.to_f
          end
        else
          note = stringFloat.to_f # MIDI note
        end
        stringFloat = ""
        escape = false
      else
        case c
        when '/' then
          ziff[:skip]=!ziff[:skip]
        when '=' then
          stringFloat+=c
        when '!' then
          # Reset node options to defaults
          addition = 0
          slideNext = false
          ziff = ziff.merge(defaults)
        when /^[A-Z]+$/ then
          stringFloat+=c
        when '.' then
          if escape then
            stringFloat = stringFloat+c
          else
            dot+=1
            dotLength = (2.0-(1.0/(2**dot))) # https://en.wikipedia.org/wiki/Dotted_note
          end
        when /^[a-z]+$/ then
          if escape then
            stringFloat+=c
          else
            noteLength = defaultDurs[c.to_sym]
          end
        when /^[0-9]+$/ then
          if escape || midi then  # Notes inside () or []
            stringFloat = stringFloat+c
          else
            dgr = c.to_i # Plain degrees 1234 etc.
          end
        when '?' then
          if escape then
            if escapeType == :pan then
              ziff[:pan] = [1,-1,0].choose
              escapeType = nil
              escape = false
            elsif escapeType == :sleep then
              stringFloat = stringFloat+rrand_i(1,9).to_s
            else
              stringFloat = stringFloat+rrand_i(0,7).to_s
            end
          else
            dgr = rrand_i(1,getScaleDegrees(ziff[:key],ziff[:scale]).length)
          end
        when '#' then
          sfaddition += 1
        when '&' then
          sfaddition -= 1
        when '+' then
          ziff[:pitch] += 12
        when '-' then
          if escape then
            stringFloat = stringFloat+c
          else
            ziff[:pitch] -= 12
          end
        when '<' then
          ziff[:amp] = ziff.fetch(:amp)+ziff.fetch(:amp_step)
        when '>' then
          ziff[:amp] = ziff.fetch(:amp)-ziff.fetch(:amp_step)
        when '~' then
          escape = true
          escapeType = controlChars[c.to_sym]
        when '^' then
          stringFloat+=c  if escape
        when '$' then
          if next_c==' ' then
            randomScale = scale_names.choose
            ziff[:scale] = randomScale
          else
            escapeType = controlChars[c.to_sym]
            escape = true
          end
        when ':' then
          if noteBuffer.length > 0 then # Loop is ending
            if loopCount<1 then # If : loop
              if (Integer(next_c) rescue false) then
                (next_c.to_i-1).times do # Numbered :3 loop
                  notes = notes.concat(noteBuffer)
                end
                skip = true # Skip next
              else
                notes = notes.concat(noteBuffer) # Normal : loop
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
            if loopCount>1 then
              notes = notes.concat(noteBuffer)
            end
          else
            raise "Use of : is mandatory before ;"
          end
        when '@' then
          # Recursive call from @ to @
          if ds then
            again = zparse(n[/\@(.*?)@/,1], defaults, shared.clone)
            notes = notes.concat(again)
          else
            ds = !ds
          end
        when '*' then
          # Recursive call from beginning to first *
          if dc then
            again = zparse(n.split('*')[0], defaults, shared.clone)
            notes = notes.concat(again)
          else
            dc = !dc
          end
        else
          # all other nonsense
        end
      end
      # If any degree was parsed, parse note and add to hasharray
      if dgr!=nil || note!=0 then
        #print "Parsed degree: "+dgr.to_s
        note = getNoteFromDgr(dgr, ziff[:key], ziff[:scale]) if dgr!=nil
        if slideNext then
          controlZiff[:degree] = dgr
          controlZiff[:note] = note
          controlZiff[:sleep] = noteLength*dotLength
          controlZiff[:pitch] = controlZiff[:pitch]+sfaddition
          if sfaddition!=0 then
            controlZiff[:pitch] = controlZiff[:pitch]-sfaddition
            sfaddition=0
          end
          controlBuffer.push(controlZiff.clone)
          if next_c == nil || next_c == ' ' then
            slideNext = false # Slide ends
            ziff[:control] = controlBuffer
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
            controlZiff.delete(:attack)
            controlZiff.delete(:release)
            controlZiff.delete(:sustain)
            controlZiff.delete(:decay)
          end
          ziff[:degree] = dgr
          ziff[:note] = note
          ziff[:sleep] = noteLength*dotLength
          ziff[:sustain] = defaults[:sustain]*(ziff[:sleep]==0 ? 1 : ziff[:sleep]) if ziff[:sustain]!=nil
          ziff[:release] = defaults[:release]*(ziff[:sleep]==0 ? 1 : ziff[:sleep])
          ziff[:pitch] = ziff[:pitch]+sfaddition
          noteBuffer.push(ziff.clone) if !slideNext && loop && loopCount<1 # : buffer
          notes.push(ziff)
          if !slideNext then
            ziff = ziff.clone
            if sfaddition!=0 then
              ziff[:pitch] = ziff[:pitch]-sfaddition
              sfaddition=0
            end
          end
        end
        dot = 0
        dotLength = 1.0
        note = 0
      elsif ziff[:chord]!=nil
        chordZiff = chordDefaults.merge(ziff.clone)
        chordZiff[:sleep] = chordZiff.delete(:chordSleep)
        chordZiff[:release] = ziff[:chordRelease]
        notes.push(chordZiff)
        noteBuffer.push(chordZiff.clone) if loop && loopCount<1 # : buffer
        ziff.delete(:chord)
      end
      # Continues loop
    end
  end
  notes
end

def getNoteFromDgr(dgr, zkey, zscale)
  if dgr==0 then
    return :r
  else
    scaleDegrees = getScaleDegrees(zkey,zscale)
    if dgr>scaleDegrees.length then
      return degree(scaleDegrees[dgr],zkey,zscale)+dgr/scaleDegrees.length*12
    else
      return degree(dgr,zkey,zscale)
    end
  end
end

def searchList(arr,query)
  result = (Float(query) != nil rescue false) ? arr[query.to_i] : arr.find { |e| e.match( /\A#{Regexp.quote(query)}/)}
  (result == nil ? query : result)
end

def mergeRates(ziff, opts)
  ziff.merge(opts) {|_,a,b| (a.is_a? Numeric) ? a * b : b }
end

def zparams(hash, name)
  hash.map{|x| x[name]}
end

def binauralDegree(ziff,defaults={})
  bziff = ziff.clone
  bziff[:pan] = -(ziff[:pan])
  bziff[:note] = hz_to_midi(midi_to_hz(bziff[:note])+bziff[:hz])
  if ziff[:sample]!=nil then
    if defaults[:rateBased] then
      bziff[:rate] = (pitch_to_ratio(hz_to_midi(midi_to_hz(ziff[:note])+ziff[:hz])-note(ziff[:key])))
    else
      bziff[:pitch] = (scale 1, bziff[:scale])[bziff[:degree]-1]+bziff[:pitch]-0.9999+(hz_to_midi(midi_to_hz(60)+bziff[:hz])-60)
    end
  end
  bziff
end

def clean(ziff)
  ziff.except(:key,:scale,:chordSleep,:chordRelease,:chordInvert,:ampStep,:rateBased,:skip,:midi)
end

def playMidiOut(md, ms, p, c)
  midi md, {sustain: ms, port: p }.tap { |hash| hash[:channel] = c if c!=nil }
end

def playZiff(ziff,defaults={})
  if ziff[:skip] then
    print "Skipping note"
  elsif ziff.has_key?(:chord) then
    if ziff[:port] then
      ziff[:chord].each { |cnote| playMidiOut(cnote, ziff[:chordRelease],ziff[:port],ziff[:channel]) }
    else
      synth ziff[:chordSynth]!=nil ? ziff[:chordSynth] : current_synth, notes: ziff[:chord], amp: ziff[:amp], pan: ziff[:pan], attack: ziff[:attack], release: ziff[:release], sustain: ziff[:sustain], decay: ziff[:decay], pitch: ziff[:pitch], note_slide: ziff[:note_slide]
    end
  elsif ziff[:port] then
    sustain = ziff[:sustain]!=nil ? ziff[:sustain] :  ziff[:release]
    playMidiOut(ziff[:note]+ziff[:pitch],sustain, ziff[:port], ziff[:channel])
  else
    if ziff[:hz]!=nil then
      ziff[:pan] = ziff[:pan]==0 ? 1 : ziff[:pan]
      bziff = binauralDegree(ziff,defaults)
      if bziff[:sample]!=nil then
        bnote = sample bziff[:sample], clean(bziff)
      else
        bnote = play clean(bziff)
      end
    end
    slide = ziff[:control]
    ziff.delete(:control)
    if ziff[:sample]!=nil then
      if defaults[:rateBased] && ziff[:note]!=nil then
        ziff[:rate] = pitch_to_ratio(ziff[:note]-note(ziff[:key]))
      elsif ziff[:degree]!=nil && ziff[:degree]!=0 then
        ziff[:pitch] = (scale 1, ziff[:scale])[ziff[:degree]-1]+ziff[:pitch]-0.999
      end
      c = sample ziff[:sample], clean(ziff)
    else
      c = play clean(ziff)
    end
    if slide != nil then
      sleep ziff[:sleep]*ziff[:note_slide]
      slide.each do |cziff|
        if cziff[:hz]!=nil then
          cziff[:pan] = cziff[:pan]==0 ? 1 : cziff[:pan]
          bziff = binauralDegree(cziff,defaults)
          control bnote, clean(bziff)
        end
        if cziff[:sample]!=nil && cziff[:degree]!=nil && cziff[:degree]!=0 then
          cziff[:pitch] = (scale 1, cziff[:scale])[cziff[:degree]-1]+cziff[:pitch]-0.999
        end
        control c, clean(cziff)
        sleep cziff[:sleep]
      end
    end
  end
end

def zarray(arr, opts=defaultOpts)
  zmel=[]
  arr.each do |item|
    if item.is_a? Array then
      zmel.push arrayToHash(item,opts)
    elsif item.is_a? Numeric then
      opts[:note] = getNoteFromDgr(item, opts[:key], opts[:scale])
      zmel.push(opts.clone)
    end
  end
  zmel
end

def arrayToHash(obj,opts=defaultOpts)
  defObj = [0,opts[:sleep],opts[:key],opts[:scale],opts[:release]]
  arrayOpts = [:note,:sleep,:key,:scale,:release]
  obj.each_with_index do |item,index|
    defObj[index] = item
  end
  defObj[0] = getNoteFromDgr(defObj[0], defObj[2], defObj[3])
  opts.merge(Hash[arrayOpts.zip(defObj)])
end

def zmidi(melody,opts={},shared={})
  shared[:midi] = true
  shared[:rateBased] = true if opts[:sample] && shared[:degreeBased]!=nil
  opts[:degree] = melody-opts[:key] if shared[:degreeBased]
  zplay(melody,opts,shared)
end

def zplay(melody,opts={},defaults={})
  opts = defaultOpts.merge(opts)
  if melody.is_a? Numeric then
    if defaults[:midi] then
      opts[:note] = melody
    else
      opts[:note] = getNoteFromDgr(melody, opts[:key], opts[:scale])
    end
    playZiff(opts,defaults)
  else
    if melody.is_a? String then
      melody = zparse(melody,opts,defaults)
      defaults[:parsed]==true
    elsif (melody.is_a? Array) && !(melody[0].is_a? Hash) then
      melody = zarray(melody,opts)
      defaults[:parsed]==true
    end
    melody.each_with_index do |ziff,index|
      ziff = mergeRates(ziff, defaults) if defaults[:parsed]==nil
      playZiff(ziff,defaults)
      sleep ziff[:sleep] if !ziff[:skip]
    end
  end
end

def zdrums(melody,opts={synth: :beep},defaults={})
  if melody.is_a? String then
    melody = zparse(melody,opts,defaults)
  end
  melody.each do |ziff|
    c = synth ziff[:synth], clean(ziff) if ziff[:note]!=nil
    control c, note: 0, amp: ziff[:amp]*2
    sleep ziff[:sleep] if melody.length>1
  end
end