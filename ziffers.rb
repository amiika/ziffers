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
    :sleep => 0.5,
    :pitch => 0.0,
    :amp => 1.0,
    :amp_slide => 0,
    :amp_step => 0.0,
    :slideNext => false,
    :note_slide => 0.5
  }
end
def zparse(n,opts=nil)
  notes, noteBuffer, rnd, chs = Array.new(4){ [] }
  loop, rndRange, rndChoose, escape, dc, ds = false, false, false,false,false,false
  stringFloat = ""
  dotLength = 1.0
  addition, sfaddition, dot, loopCount = 0, 0, 0, 0
  slideNext = false
  escapeType = nil
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
  defaults = defaultOpts
  if opts!=nil then
    defaults = defaults.merge(opts)
  end
  type = {
    'A': :amp, #Volume
    'V': :attack,
    'P': :pan,
    'D': :decay,
    'K': :sustain, #Keep
    'R': :release,
    'Z': :sleep, #Zzz
    'T': :pitch, # Tuning
    'K': :key,
    'S': :scale,
    '~': :note_slide
  }
  durs.default = 0.25
  ziff = defaults.clone
  zkey = ziff.fetch(:key)
  zscale = ziff.fetch(:scale)
  scaleDegrees = Array.new(scale(zkey,zscale).length){ |i| (i+1) }.ring
  chars = n.chars
  chars.to_enum.each_with_index do |c, index|
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
        if stringFloat == nil || stringFloat.length==0 then
          ziff[escapeType] = defaults.fetch(escapeType)
        elsif escapeType == :scale then
          if (Float(stringFloat) != nil rescue false) then
            ziff[escapeType] = scale_names[stringFloat.to_i]
          else
            ziff[escapeType] = findScale stringFloat.to_s
          end
        elsif escapeType == :key then
          ziff[escapeType] = stringFloat.to_s
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
        ziff[:sleep] = durs[c.to_sym]
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
      slideNext = !slideNext
      if slideNext then
        escape = true
        escapeType = type[c.to_sym]
      else
        escape = false
      end
    when '|' then
      # Do something
    when '$' then
      ziff[:scale] = scale_names.choose
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
    
    if dgr!=nil then
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
      
      ziff[:note] = note
      ziff[:sleep] = ziff.fetch(:sleep)*dotLength
      ziff[:slideNext] = slideNext
      
      # Add note to buffer if looping with :
      if loop && loopCount<1 then
        noteBuffer.push(ziff)
      end
      
      notes.push(ziff)
      dot = 0
      dotLength = 1.0
      ziff = ziff.clone
    end
  end
  notes
end

def findScale(query)
  result = scale_names.find { |e| e.match( /\A#{Regexp.quote(query)}/)}
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
    zz = ziff[:sleep]
    while ziff[:slideNext]
      ziff = melody.tick
      control c, note: ziff[:note], amp: ziff[:amp], pan: ziff[:pan], pitch: ziff[:pitch]
      sleep ziff[:sleep]
    end
    sleep zz
  end
end

def zplay(melody,opts=nil)
  if melody.is_a? String then
    melody = zparse(melody,opts)
  end
  n=0
  until n>=melody.length do
      ziff = melody[n]
      c = play ziff[:note], amp: ziff[:amp], pan: ziff[:pan], attack: ziff[:attack], release: ziff[:release], sustain: ziff[:sustain], decay: ziff[:decay], pitch: ziff[:pitch], note_slide: ziff[:note_slide]
      zz = ziff[:sleep]
      while ziff[:slideNext] && n+1<melody.length do
          n=n+1
          ziff = melody[n]
          control c, note: ziff[:note], amp: ziff[:amp], pan: ziff[:pan], pitch: ziff[:pitch]
          sleep ziff[:sleep]
        end
        sleep zz
        n=n+1
      end
    end
    
