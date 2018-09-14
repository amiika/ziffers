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

def synthDefaults
  defaults = {
    :chordSleep => 0,
    :chordRelease => 1
  }
end

def defaultOpts
  defaults = {
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

def getTypes
  type = {
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
    '^': :synth, # Instrument
    'C': :chord,
  }
end

def getScaleDegrees(zkey,zscale)
  scaleDegrees = Array.new(scale(zkey,zscale).length){ |i| (i+1) }.ring
end

def zparse(n,opts=nil)
  notes, noteBuffer, controlBuffer, rnd, chs = Array.new(5){ [] }
  loop, rndRange, rndChoose, escape, dc, ds = false, false, false,false,false,false
  stringFloat = ""
  noteLength, dotLength = 0.25, 1.0
  addition, sfaddition, dot, loopCount = 0, 0, 0, 0
  slideNext = false
  escapeType = nil
  durs = defaultDurs
  defaults = defaultOpts
  if opts!=nil then
    defaults = defaults.merge(opts)
  end
  type = getTypes
  durs.default = 0.25
  ziff = defaults.clone
  defaults = synthDefaults.merge(defaults)
  zkey = ziff.fetch(:key)
  zscale = ziff.fetch(:scale)
  scaleDegrees = getScaleDegrees(zkey,zscale)
  # Loop chars
  chars = n.chars
  chars.to_enum.each_with_index do |c, index|
    next_c = chars[index+1]
    dgr = nil
    case c
    when '!' then
      addition = 0
      slideNext = false
      ziff = ziff.merge(defaults)
    when /^[A-Z]+$/ then
      if !escape && type.key?(c.to_sym) then
        escape = true
        escapeType = type[c.to_sym]
      else
        stringFloat+=c
      end
    when ' '
      if escape then
        #print escapeType.to_s+":"+stringFloat.to_s
        if stringFloat == nil || stringFloat.length==0 then
          ziff[escapeType] = defaults.fetch(escapeType)
        elsif escapeType == :scale then
          ziff[escapeType] = searchList(scale_names, stringFloat)
          # If scale changes get new ring of degrees
          zscale = ziff.fetch(:scale)
          scaleDegrees = getScaleDegrees(zkey, zscale)
        elsif escapeType == :synth then
          ziff[escapeType] = searchList(synth_names, stringFloat)
        elsif escapeType == :key then
          ziff[escapeType] = stringFloat.to_s
        elsif escapeType == :chord then
          zchord = chord_degree(stringFloat.to_i,zkey,zscale,3) # Add more options?
          ziff[escapeType] = zchord
        elsif escapeType == :sleep then
          noteLength = stringFloat.to_f
          ziff[escapeType] = stringFloat.to_f
        else
          ziff[escapeType] = stringFloat.to_f
        end
        stringFloat = ""
        escape = false
      end
    when '.' then
      if escape then
        stringFloat = stringFloat+c
      else
        dot+=1
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
      if rndRange || rndChoose then
        if rndRange then
          if rnd.length > 2 then raise 'Too many parameters' end
          rnd.push(c.to_i)
        elsif rndChoose then
          chs.push(c.to_i)
        end
      elsif escape then
        stringFloat = stringFloat+c
      else
        # Plain notes 1234 etc.
        dgr = c.to_i
      end
    when '?' then
      dgr = rrand_i(1,scaleDegrees.length)
    when '#' then
      sfaddition += 1
    when '&' then
      sfaddition -= 1
    when '+' then
      addition += 12
    when '-' then
      if escape then
        stringFloat = stringFloat+c
      else
        addition += -12
      end
    when '<' then
      ziff[:amp] = ziff.fetch(:amp)+ziff.fetch(:amp_step)
    when '>' then
      ziff[:amp] = ziff.fetch(:amp)-ziff.fetch(:amp_step)
    when '%' then
      ziff[:pan] = [1,-1,0].choose
    when '~' then
      escape = true
      escapeType = type[c.to_sym]
    when '^' then
      escape = true
      escapeType = type[c.to_sym]
    when '$' then
      if next_c==' ' then
        randomScale = scale_names.choose
        ziff[:scale] = randomScale
        scaleDegrees = getScaleDegrees(zkey, randomScale)
      else
        escapeType = type[c.to_sym]
        escape = true
      end
    when ':' then
      if noteBuffer.length > 0 then
        # Normal loop must be ending, add buffer to note list
        if loopCount<2 then
          notes = notes.concat(noteBuffer)
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
      rndRange = true
    when ')' then
      rndRange = false
      dgr = rrand_i(rnd[0],rnd[1])
      rnd = []
    when '[' then
      rndChoose = true
    when ']' then
      rndChoose = false
      dgr = chs.choose
      chs = []
    when '@' then
      # Recursive call from @ to @
      if ds then
        again = zparse(n[/\@(.*?)@/,1], ziff.clone)
        notes = notes.concat(again)
      else
        ds = !ds
      end
    when '*' then
      # Recursive call from beginning to first !
      if dc then
        again = zparse(n.split('*')[0], ziff.clone)
        notes = notes.concat(again)
      else
        dc = !dc
      end
    else
      # Spaces, commas and all other nonsense
    end
    
    # If any degree was parsed, parse note and add to hasharray
    if dgr!=nil then
      #print "Parsed degree: "+dgr.to_s
      note = nil
      if dgr==0 then
        note = :r
      else
        zkey = ziff.fetch(:key)
        zscale = ziff.fetch(:scale)
        # Transpose if needed
        if dgr>scaleDegrees.length then
          note = degree(scaleDegrees[dgr],zkey,zscale)
          note+=12
        else
          note = degree(dgr,zkey,zscale)
        end
        # Add sharps and flats
        note = note + sfaddition
        sfaddition = 0
        # Add +- additions
        note = note + addition
      end
      
      if slideNext then
        
        #Slide starts
        controlZiff = ziff.clone
        controlZiff[:note] = note
        controlZiff[:sleep] = controlZiff[:sleep]*dotLength
        # Remove nonmodulatable params
        controlZiff.delete(:attack)
        controlZiff.delete(:release)
        controlZiff.delete(:sustain)
        controlZiff.delete(:decay)
        
        controlBuffer.push(controlZiff)
        
        if next_c == nil || next_c == ' ' then
          #print "Slide ends: "+controlBuffer.length.to_s
          slideNext = false
          ziff[:control] = controlBuffer
          ziff[:release] = ziff[:sleep] * (ziff[:control].length+1)
          controlBuffer = []
        end
        
      else
        
        if escapeType==:note_slide then
          #print "Start slide"
          slideNext=true
          escapeType=nil
        end
        
        #print "Create new object"
        ziff = ziff.clone
        ziff[:control] = nil
        ziff[:note] = note
        ziff[:sleep] = noteLength*dotLength
        ziff[:release] = defaults[:release]*(noteLength*2)
        
        # Add note to buffer if looping with :
        if loop && loopCount<1 then
          noteBuffer.push(ziff.clone)
        end
        
        notes.push(ziff)
        
      end
      
      dot = 0
      dotLength = 1.0
      
    elsif ziff[:chord]!=nil
      chordZiff = ziff.clone
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
  notes
end

def searchList(arr,query)
  if (Float(query) != nil rescue false) then
    result = arr[query.to_i]
  else
    result = arr.find { |e| e.match( /\A#{Regexp.quote(query)}/)}
  end
  
  if result==nil
    query
  else
    result
  end
  
end

def zparams(hash, name)
  hash.map{|x| x[name]}
end

def zloop(melody,opts=nil)
  if melody.is_a? String then
    melody = zparse(melody, opts)
  end
  melody = melody.ring
  loop do
    ziff = melody.tick
    c = play ziff[:note], amp: ziff[:amp], pan: ziff[:pan], attack: ziff[:attack], release: ziff[:release], sustain: ziff[:sustain], decay: ziff[:decay], pitch: ziff[:pitch], note_slide: ziff[:note_slide]
    
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

def zplay(melody,opts={})
  # If melody is string then parse 
  if melody.is_a? String then
    melody = zparse(melody,opts)
    opts = {}
  end
  melody.each do |ziff|
      # Merge opts to each object
      ziff = mergeOpts(ziff, opts)
      c = play ziff[:note], amp: ziff[:amp], pan: ziff[:pan], attack: ziff[:attack], release: ziff[:release], sustain: ziff[:sustain], decay: ziff[:decay], pitch: ziff[:pitch], note_slide: ziff[:note_slide] if ziff[:note]!=nil
    if ziff[:control] != nil then
      sleep ziff[:sleep]/3
      ziff[:control].each do |cziff|
        control c, note: cziff[:note], amp: cziff[:amp], pan: cziff[:pan], pitch: cziff[:pitch]
        sleep cziff[:sleep]
      end
    else
      sleep ziff[:sleep] if melody.length>1
    end
  end
end

def zbin(melody,opts={hz: 4, right: true})
  melody.each do |ziff|
    # Merge opts to each object
    ziff = mergeOpts(ziff,opts)
    midiHz = midi_to_hz(ziff[:note])
    diffNote = hz_to_midi(midiHz+opts[:hz])
    print diffNote
    c = play ziff[:note], amp: ziff[:amp], pan: 1, attack: ziff[:attack], release: ziff[:release], sustain: ziff[:sustain], decay: ziff[:decay], pitch: ziff[:pitch], note_slide: ziff[:note_slide] if ziff[:note]!=nil
    d = play diffNote, amp: ziff[:amp], pan: -1, attack: ziff[:attack], release: ziff[:release], sustain: ziff[:sustain], decay: ziff[:decay], pitch: ziff[:pitch], note_slide: ziff[:note_slide] if ziff[:note]!=nil
    
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
    opts = {}
  end
  melody.each do |ziff|
    ziff = mergeOpts(ziff, opts)
    c = play ziff[:note], amp: ziff[:amp], pan: ziff[:pan], pitch: ziff[:pitch], note_slide: ziff[:note_slide] if ziff[:note]!=nil
    control c, note: 0, amp: ziff[:amp]*2, pan: ziff[:pan]
    sleep ziff[:sleep] if melody.length>1
  end
end

def mergeOpts(ziff, opts)
  ziff.merge(opts) {|_,a,b| (a.is_a? Numeric) ? a * b : b }
end

