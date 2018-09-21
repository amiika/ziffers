def defaultDurs
  durs = {
    'm': 8.0,
    'l': 4.0,
    'd': 2.0,
    'w': 1.0,
    'h': 0.5,
    'q': 0.25,
    'e': 0.125,
    's': 0.0625,
    't': 0.03125,
    'f': 0.015625
  }
end

def zkeys
  (ring "C","Db","D","Eb","E","F","Gb","G","Ab","A","Bb","B")
end

def synthDefaults
  defaults = {
    :chordSleep => 0,
    :chordRelease => 1
  }
end

def defaultSampleOpts
  defaultSampleOpts = {
    :sample => :ambi_piano,
    :rate => 1,
    :scale => :major,
    :pan => 0,
    :attack => 0.0,
    :decay => 0.0,
    :release => 0.0,
    #:sustain => sample_duration(:ambi_piano),
    :sleep => 0.25,
    :pitch => 0.0,
    :amp => 1.0,
    :amp_slide => 0,
    :amp_step => 0.5,
    :note_slide => 0.5,
    :control => nil
  }
end

def defaultOpts
  defaultOpts = {
    :key => :c,
    :scale => :major,
    :pan => 0,
    :pan_slide => 0,
    :attack => 0.0,
    :decay => 0.0,
    :release => 1.0,
    :sustain => 0.0,
    :sleep => 0.25,
    :pitch => 0.0,
    :amp => 1.0,
    :amp_slide => 0,
    :amp_step => 0.5,
    :note_slide => 0.5,
    :control => nil
  }
end

def getControlChars
  controlChars = {
    'V': :amp, # Volume
    'E': :env_curve,
    'A': :attack,
    'P': :pan,
    'D': :decay,
    'S': :sustain, #Keep
    'R': :release,
    'Z': :sleep, #Zzz
    'T': :pitch, # Tuning
    'K': :key,
    '$': :scale,
    '~': :note_slide,
    '^': :synth,
    'C': :chord,
  }
end

def getScaleDegrees(zkey,zscale)
  scaleDegrees = Array.new(scale(zkey,zscale).length){ |i| (i+1) }.ring
end

def zparse(n,opts=nil,defaults=defaultOpts)
  print defaults
  notes, noteBuffer, controlBuffer, rnd = Array.new(4){ [] }
  loop, escape, dc, ds = false, false, false,false
  stringFloat = ""
  noteLength, dotLength = 0.25, 1.0
  sfaddition, dot, loopCount = 0, 0, 0, 0
  skip, slideNext = false, false
  escapeType = nil
  durs = defaultDurs
  if opts!=nil then
    defaults = defaults.merge(opts)
  end
  controlChars = getControlChars
  durs.default = 0.25
  
  # Clone defaults to current node
  ziff, controlZiff = defaults.clone
  # Merge synth options to defaults
  defaults = synthDefaults.merge(defaults)
  
  # Loop chars
  chars = n.chars
  chars.to_enum.each_with_index do |c, index|
    next_c = chars[index+1]
    dgr = nil
    
    if skip then
      skip = false # Skip next char and continue
    else
      case c
      when '!' then
        # Reset node options to defaults
        addition = 0
        slideNext = false
        ziff = ziff.merge(defaults)
      when /^[A-Z]+$/ then
        if !escape && controlChars.key?(c.to_sym) then
          # If char Following chars are readed to stringFloat until next ' '
          escape = true
          escapeType = controlChars[c.to_sym]
          print "escape: "+escapeType.to_s
        else
          stringFloat+=c
        end
      when ' '
        # Parse current string or float
        if escape then
          #print escapeType.to_s+":"+stringFloat.to_s
          if stringFloat == nil || stringFloat.length==0 then
            ziff[escapeType] = defaults.fetch(escapeType)
          elsif escapeType == :scale then
            ziff[:scale] = searchList(scale_names, stringFloat)
          elsif escapeType == :synth then
            ziff[:synth] = searchList(synth_names, stringFloat)
          elsif escapeType == :key then
            ziff[:key] = stringFloat.to_s
          elsif escapeType == :chord then
            ziff[:chord] = chord_degree(stringFloat.to_i,ziff[:key],ziff[:scale],3) # Add more options?
          elsif escapeType == :sleep then
            noteLength = stringFloat.to_f
            ziff[:sleep] = noteLength
          else
            print stringFloat
            ziff[escapeType] = stringFloat.to_f
            print ziff[escapeType]
          end
          stringFloat = ""
          escape = false
        end
      when '.' then
        if escape then
          stringFloat = stringFloat+c
        else
          dot+=1
          # https://en.wikipedia.org/wiki/Dotted_note
          dotLength = (2.0-(1.0/(2**dot)))
        end
      when /^[a-z]+$/ then
        # Set note length
        if escape then
          stringFloat+=c
        else
          noteLength = durs[c.to_sym]
        end
      when /^[0-9]+$/ then
        # Notes inside () or []
        if escape then
          if escapeType == 'rrandom' then
            if rnd.length > 2 then raise 'Too many parameters' end
            rnd.push(c.to_i)
          elsif escapeType == 'choose' then
            rnd.push(c.to_i)
          elsif escape then
            stringFloat = stringFloat+c
          end
        else
          # Plain notes 1234 etc.
          dgr = c.to_i
        end
      when '?' then
        if escape then
          if escapeType == :pan then
            ziff[:pan] = [1,-1,0].choose
            escapeType = nil
            escape = false
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
      when '%' then
        # Todo
      when '~' then
        escape = true
        escapeType = controlChars[c.to_sym]
      when '^' then
        escape = true
        escapeType = controlChars[c.to_sym]
      when '$' then
        if next_c==' ' then
          randomScale = scale_names.choose
          ziff[:scale] = randomScale
        else
          escapeType = controlChars[c.to_sym]
          escape = true
        end
      when ':' then
        if noteBuffer.length > 0 then
          # Loop must be ending, add buffer notes to list
          if loopCount<1 then
            # Skip numbered repeat in ;-loop sections
            if (Integer(next_c) rescue false) then
              (next_c.to_i-1).times do
                notes = notes.concat(noteBuffer)
              end
              skip = true # Skip next char
            else
              notes = notes.concat(noteBuffer)
            end
          end
          loopCount = 0
          noteBuffer = []
          loop = false
        else
          # Loop is starting
          loop = true
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
      when '(' then
        escape = true
        escapeType = 'rrandom'
      when ')' then
        escape = false
        escapeType = nil
        dgr = rrand_i(rnd[0],rnd[1])
        rnd = []
      when '[' then
        escape = true
        escapeType = 'choose'
      when ']' then
        escape = false
        escapeType = nil
        dgr = rnd.choose
        rnd = []
      when '@' then
        # Recursive call from @ to @
        if ds then
          again = zparse(n[/\@(.*?)@/,1], ziff.clone,defaults=defaults)
          notes = notes.concat(again)
        else
          ds = !ds
        end
      when '*' then
        # Recursive call from beginning to first *
        if dc then
          again = zparse(n.split('*')[0], ziff.clone,defaults=defaults)
          notes = notes.concat(again)
        else
          dc = !dc
        end
      else
        # all other nonsense
      end
      
      # If any degree was parsed, parse note and add to hasharray
      if dgr!=nil then
        #print "Parsed degree: "+dgr.to_s
        
        note = getNoteFromDgr(dgr, ziff[:key], ziff[:scale])
        
        if slideNext then
          
          controlZiff[:degree] = dgr
          controlZiff[:note] = note
          controlZiff[:sleep] = noteLength*dotLength
          controlZiff[:pitch] = controlZiff[:pitch]+sfaddition
          
          controlBuffer.push(controlZiff)
          controlZiff = controlZiff.clone
          
          if sfaddition!=0 then
            controlZiff[:pitch] = controlZiff[:pitch]-sfaddition
            sfaddition=0
          end
          
          if next_c == nil || next_c == ' ' then
            #print "Slide ends: "+controlBuffer.length.to_s
            slideNext = false
            ziff[:control] = controlBuffer
            ziff[:release] = ziff[:sleep] * (ziff[:control].length+1)
            ziff = ziff.clone
            ziff[:control] = nil
            controlBuffer = []
          end
          
        else
          
          if escapeType==:note_slide then
            #print "Start slide"
            slideNext=true
            escapeType=nil
            # Remove nonmodulatable params
            controlZiff = ziff.clone
            controlZiff.delete(:attack)
            controlZiff.delete(:release)
            controlZiff.delete(:sustain)
            controlZiff.delete(:decay)
          end
          
          ziff[:degree] = dgr
          ziff[:note] = note
          ziff[:sleep] = noteLength*dotLength
          ziff[:release] = defaults[:release]*(noteLength*2)
          ziff[:pitch] = ziff[:pitch]+sfaddition
          
          # Add note to buffer if looping with :
          if loop && loopCount<1 then
            noteBuffer.push(ziff)
          end
          
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
        
      elsif ziff[:chord]!=nil
        chordZiff = ziff.clone
        chordZiff[:control] = nil
        chordZiff[:sleep] = defaults[:chordSleep]
        chordZiff[:release] = defaults[:chordRelease]
        notes.push(chordZiff)
        if loop && loopCount<1 then
          noteBuffer.push(chordZiff)
        end
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
  if (Float(query) != nil rescue false) then
    result = arr[query.to_i]
  else
    result = arr.find { |e| e.match( /\A#{Regexp.quote(query)}/)}
  end
  (result == nil ? query : result)
end

def zparams(hash, name)
  hash.map{|x| x[name]}
end

def playDegree(ziff)
  play ziff[:note], amp: ziff[:amp], pan: ziff[:pan], attack: ziff[:attack], release: ziff[:release], sustain: ziff[:sustain], decay: ziff[:decay], pitch: ziff[:pitch], note_slide: ziff[:note_slide] if ziff[:note]!=nil
end

def zplay(melody,opts={})
  opts = defaultOpts.merge(opts)
  if melody.is_a? Numeric then
    opts[:note] = getNoteFromDgr(melody, opts[:key], opts[:scale])
    playDegree(opts)
  else
    if melody.is_a? String
      melody = zparse(melody,opts)
      opts[:parsed]==true
    end
    melody.each do |ziff|
      print ziff
      if ziff.is_a? Numeric then
        opts[:note] = getNoteFromDgr(ziff, opts[:key], opts[:scale])
        ziff = opts
        print ziff
      else
        ziff = mergeOpts(ziff, opts) if opts[:parsed]!=nil
      end
      c = playDegree(ziff)
      if ziff[:control] != nil then
        sleep ziff[:sleep]/3
      ziff[:control].each do |cziff|
        control c, note: cziff[:note], amp: cziff[:amp], pan: cziff[:pan], pitch: cziff[:pitch]
        sleep cziff[:sleep]
      end
    else
      sleep ziff[:sleep]
    end
  end
end
end

def zbin(melody,opts={hz: 4, right: true})
  melody.each do |ziff|
    # Merge opts to each object
    ziff = mergeOpts(ziff,opts)
    midiHz = midi_to_hz(ziff[:note])
    diffNote = hz_to_midi(midiHz+opts[:hz])
    c = play ziff[:note], amp: ziff[:amp], pan: ziff[:pan] == 1 ? -1 : 1, attack: ziff[:attack], release: ziff[:release], sustain: ziff[:sustain], decay: ziff[:decay], pitch: ziff[:pitch], note_slide: ziff[:note_slide] if ziff[:note]!=nil
    d = play diffNote, amp: ziff[:amp], pan: ziff[:pan] == 1 ? 1 : -1, attack: ziff[:attack], release: ziff[:release], sustain: ziff[:sustain], decay: ziff[:decay], pitch: ziff[:pitch], note_slide: ziff[:note_slide] if ziff[:note]!=nil

    if ziff[:control] != nil then
      sleep ziff[:sleep]/3
        ziff[:control].each do |cziff|
          midiHz = midi_to_hz(cziff[:note])
          diffNote = hz_to_midi(midiHz+opts[:hz])
          control c, note: cziff[:note], amp: cziff[:amp], pan: 1, pitch: cziff[:pitch]
          control d, note: diffNote, amp: cziff[:amp], pan: -1, pitch: cziff[:pitch]
          sleep cziff[:sleep]
        end
      else
        sleep ziff[:sleep] if melody.length>1
      end
    end
  end
  
  def zsynth(melody,opts=synthDefaults)
    if melody.is_a? String then
      melody = zparse(melody,opts)
    end
    n=0
    until n>=melody.length do
        ziff = melody[n]
        if ziff.has_key?(:chord) then
          c = synth ziff[:synth], notes: ziff[:chord], amp: ziff[:amp], pan: ziff[:pan], attack: ziff[:attack], release: ziff[:release], sustain: ziff[:sustain], decay: ziff[:decay], pitch: ziff[:pitch], note_slide: ziff[:note_slide]
        else
          c = synth ziff[:synth], note: ziff[:note], amp: ziff[:amp], pan: ziff[:pan], attack: ziff[:attack], release: ziff[:release], sustain: ziff[:sustain], decay: ziff[:decay], pitch: ziff[:pitch], note_slide: ziff[:note_slide]
        end
        if ziff[:control] != nil then
          sleep ziff[:sleep]/3
      ziff[:control].each do |cziff|
        control c, note: cziff[:note], amp: cziff[:amp], pan: cziff[:pan], pitch: cziff[:pitch]
        sleep cziff[:sleep]
      end
    else
      sleep ziff[:sleep] if melody.length>1
    end
    n=n+1
  end
end

def zdrums(melody,opts={})
  if melody.is_a? String then
    melody = zparse(melody,opts)
    opts[:parsed] = true
  end
  melody.each do |ziff|
    ziff = mergeOpts(ziff, opts) if opts[:parsed]!=nil
    c = synth ziff[:synth], note: ziff[:note], amp: ziff[:amp], pan: ziff[:pan], pitch: ziff[:pitch], note_slide: ziff[:note_slide] if ziff[:note]!=nil
    control c, note: 0, amp: ziff[:amp]*2, pan: ziff[:pan]
    sleep ziff[:sleep] if melody.length>1
  end
end

def mergeOpts(ziff, opts)
  ziff.merge(opts) {|_,a,b| (a.is_a? Numeric) ? a * b : b }
end

def zsample(melody,opts,rateBased=false)
  opts = {} if opts==nil
  if melody.is_a? String then
    melody = zparse(melody,opts,defaultSampleOpts)
    opts[:parsed] = false
  else
    opts[:parsed] = true
  end
  melody.each do |ziff|
    ziff = mergeOpts(ziff, opts) if opts[:parsed]
    c = sample ziff[:sample], rate: (rateBased ? pitch_to_ratio(ziff[:note]-note(ziff[:key])) : ziff[:rate]), pitch: (rateBased ? ziff[:pitch] : (scale 1, ziff[:scale])[ziff[:degree]-1]+ziff[:pitch]-0.9999), amp: ziff[:amp], attack: ziff[:attack], decay: ziff[:decay], sustain: ziff[:sustain], release: ziff[:release], pitch_slide: 0.5 if ziff[:degree]!=0
    if ziff[:control] != nil then
      sleep ziff[:sleep]/3
          ziff[:control].each do |cziff|
            control c, pitch: (scale 1, ziff[:scale])[cziff[:degree]-1]+cziff[:pitch]-0.9999, amp: cziff[:amp] if cziff[:degree]!=0
            sleep cziff[:sleep]
          end
        else
          sleep ziff[:sleep] if melody.length>1
        end
      end
    end
