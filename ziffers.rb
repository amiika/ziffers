def defaultDurs
  durs = {'m': 8.0, 'l': 4.0, 'd': 2.0, 'w': 1.0, 'h': 0.5, 'q': 0.25, 'e': 0.125, 's': 0.0625, 't': 0.03125,'f': 0.015625 }
end

def zkeys
  (ring "C","Db","D","Eb","E","F","Gb","G","Ab","A","Bb","B")
end

def chordDefaults
  defaults = { :chordSleep => 0, :chordRelease => 1, :chordInvert => 0 }
end

def defaultSampleOpts
  defaultSampleOpts = {
    :key => :c,
    :scale => :major,
    :sample => :ambi_piano,
    :rate => 1,
    :scale => :major,
    :pan => 0,
    :release => 0.0
  }
end

def defaultOpts
  defaultOpts = {
    :key => :c,
    :synth => :beep,
    :scale => :major,
    :release => 1.0,
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
end

def getControlChars
  controlChars = {
    'A': :amp,
    'E': :env_curve,
    'C': :attack,
    'P': :pan,
    'D': :decay,
    'S': :sustain, #Keep
    'R': :release,
    'Z': :sleep, #Zzz
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

def replaceRandomSyntax(n)
  # Replace random values inside [] and ()
  cArr = n.scan(/\[.*?\]/)
  cArr.each do |s|
    n = n.sub(s,s[1,s.length-2].split(",").choose)
  end
  rArr = n.scan(/\(.*?\)/)
  rArr.each do |s|
    revl = s[1,s.length-2].split(",")
    if revl.length > 2 then raise 'Too many parameters' end
    n = n.sub(s,(rrand_i revl[0].to_i, revl[1].to_i).to_s)
  end
  n
end

def zparse(n,opts=nil,defaults=defaultOpts)
  notes, noteBuffer, controlBuffer = Array.new(3){ [] }
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
  # Clone defaults to current nodes: ziff = degree node, controlZiff = slide node
  ziff, controlZiff = defaults.clone
  n = replaceRandomSyntax(n)
  # Loop chars
  chars = n.chars
  chars.to_enum.each_with_index do |c, index|
    next_c = chars[index+1]
    dgr = nil
    if skip then
      skip = false # Skip next char and continue
    else
      if !escape && controlChars.key?(c.to_sym)
        escape = true
        escapeType = controlChars[c.to_sym]
        stringFloat+=c if(escapeType == :chord)
        chars.push(" ") if(escapeType == :chord && next_c==nil)
      elsif escape && (c==' ' || next_c==nil)
        stringFloat+=c if next_c==nil && c!=' '
        #print escapeType.to_s+": "+stringFloat.to_s
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
          ziff = chordDefaults.merge(ziff)
          parsedChord = stringFloat.split("^")
          if parsedChord.length>1 then
            chordRoot = degree parsedChord[0].to_sym, ziff[:key], ziff[:scale]
            ziff[:chord] = chord_invert chord(chordRoot, parsedChord[1]), ziff[:chordInvert]
          else
            ziff[:chord] = chord_invert chord_degree(parsedChord[0].to_sym,ziff[:key],ziff[:scale],3), ziff[:chordInvert]
          end
        elsif escapeType == :sleep then
          noteLength = stringFloat.to_f
          ziff[:sleep] = noteLength
        else
          # ~ and something else?
          ziff[escapeType] = stringFloat.to_f
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
            # https://en.wikipedia.org/wiki/Dotted_note
            dotLength = (2.0-(1.0/(2**dot)))
          end
        when /^[a-z]+$/ then
          if escape then
            stringFloat+=c
          else
            noteLength = durs[c.to_sym]
          end
        when /^[0-9]+$/ then
          # Notes inside () or []
          if escape then
            stringFloat = stringFloat+c
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
            noteBuffer.push(ziff.clone)
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
        ziff = chordDefaults.merge(ziff)
        chordZiff = ziff.clone
        chordZiff[:control] = nil
        chordZiff[:sleep] = ziff[:chordSleep]
        chordZiff[:release] = ziff[:chordRelease]
        notes.push(chordZiff)
        if loop && loopCount<1 then
          noteBuffer.push(chordZiff.clone)
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
  result = (Float(query) != nil rescue false) ? arr[query.to_i] : arr.find { |e| e.match( /\A#{Regexp.quote(query)}/)}
  (result == nil ? query : result)
end

def mergeOpts(ziff, opts)
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

def playDegrees(ziff,defaults={})
  if ziff[:skip]
  elsif ziff.has_key?(:chord) then
    ziff = chordDefaults.merge(ziff)
    synth ziff[:chordSynth]!=nil ? ziff[:chordSynth] : current_synth, notes: ziff[:chord], amp: ziff[:amp], pan: ziff[:pan], attack: ziff[:attack], release: ziff[:release], sustain: ziff[:sustain], decay: ziff[:decay], pitch: ziff[:pitch], note_slide: ziff[:note_slide]
  else
    if ziff[:hz]!=nil then
      ziff[:pan] = ziff[:pan]==0 ? 1 : ziff[:pan]
      bziff = binauralDegree(ziff,defaults)
      if bziff[:sample]!=nil then
        bnote = sample bziff[:sample], bziff
      else
        bnote = play bziff
      end
    end
    slide = ziff[:control]
    ziff.delete(:control)
    if ziff[:sample]!=nil && ziff[:degree]!=nil && ziff[:degree]!=0 then
      if defaults[:rateBased] then
        ziff[:rate] = pitch_to_ratio(ziff[:note]-note(ziff[:key]))
        print ziff[:rate]
      else
        ziff[:pitch] = (scale 1, ziff[:scale])[ziff[:degree]-1]+ziff[:pitch]-0.999
      end
      c = sample ziff[:sample], ziff
    else
      c = play ziff
    end
    if slide != nil then
      sleep ziff[:sleep]*ziff[:note_slide]
      slide.each do |cziff|
        if cziff[:hz]!=nil then
          cziff[:pan] = cziff[:pan]==0 ? 1 : cziff[:pan]
          bziff = binauralDegree(cziff,defaults)
          control bnote, bziff
        end
        if cziff[:sample]!=nil && cziff[:degree]!=nil && cziff[:degree]!=0 then
          cziff[:pitch] = (scale 1, cziff[:scale])[cziff[:degree]-1]+cziff[:pitch]-0.999
        end
        control c, cziff
        sleep cziff[:sleep]
      end
    end
  end
end

def zplay(melody,opts={},defaults={})
  opts = defaultOpts.merge(opts)
  if melody.is_a? Numeric then
    opts[:note] = getNoteFromDgr(melody, opts[:key], opts[:scale])
    playDegrees(opts,defaults)
  else
    if melody.is_a? String
      melody = zparse(melody,opts)
      opts[:parsed]==true
    end
    melody.each_with_index do |ziff,index|
      if ziff.is_a? Numeric then
        opts[:note] = getNoteFromDgr(ziff, opts[:key], opts[:scale])
        ziff = opts
      else
        ziff = mergeOpts(ziff, opts) if opts[:parsed]!=nil
      end
      playDegrees(ziff,defaults)
      sleep ziff[:sleep] if !ziff[:skip]
    end
  end
end

def zdrums(melody,opts={})
  if melody.is_a? String then
    melody = zparse(melody,opts)
    opts[:parsed] = true
  end
  melody.each do |ziff|
    ziff = mergeOpts(ziff, opts) if opts[:parsed]!=nil
    c = synth ziff[:synth], ziff if ziff[:note]!=nil
    control c, note: 0, amp: ziff[:amp]*2
    sleep ziff[:sleep] if melody.length>1
  end
end
