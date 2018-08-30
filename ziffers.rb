def zparse(n,key=:c, scale=:major,d=0.5, a=0.25)
  notes, durations, noteBuffer, durationBuffer, rnd, chs = Array.new(6){ [] }
  loop, rndRange, rndChoose, parseFloat = false,false,false,false
  noteLength = d
  stringFloat = ""
  dotLength = 1.0
  addition, sfaddition, dot, loopCount, vol, pan = 0, 0, 0, 0, 0, 0
  slide = false
  scaleDegrees = Array.new(scale(key,scale).length){ |i| (i+1) }.ring
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
  durs.default = 0.25
  n.each_char do |c|
    dgr = nil
    case c
    when '\'' then
      if parseFloat then
        noteLength = stringFloat.to_f
        parseFloat = !parseFloat
        stringFloat = ""
      else
        parseFloat = true
      end
    when '.' then
      if parseFloat then
        stringFloat = stringFloat+c
      else
        dot+=1
        dotLength = (2.0-(1.0/(2**dot)))
      end
    when /^[a-z]+$/ then
      # Set note length
      noteLength = durs[c.to_sym]
      #when '0' then
      # note = :r
    when /^[0-9]+$/ then
      # Notes inside () or []
      if rndRange || rndChoose then
        if rndRange then
          if rnd.length > 2 then raise 'Too many parameters' end
          rnd.push(c.to_i)
        elsif rndChoose then
          chs.push(c.to_i)
        end
      elsif parseFloat then
        stringFloat = stringFloat+c
      else
        # Plain notes 1234 etc.
        dgr = c.to_i
      end
    when '?' then
      dgr = rrand_i(1,scaleDegrees.length)
    when '#' then
      sfaddition += 1
    when '*' then
      sfaddition -= 1
    when '+' then
      addition += 12
    when '-' then
      addition += -12
    when '<' then
      vol +=a
    when '>' then
      vol -=a
    when 'C'
      pan = 0
    when 'L'
      pan = -1
    when 'R'
      pan = 1
    when '%' then
      addition+=[12,-12].choose
    when '~' then
      slide = !slide
    when '|' then
      noteLength = d
      addition = 0
      vol = 0
      pan = 0
      slide = false
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
    when '}' then
      # Recursive call from { to }
      again = zparse(n[/.*\{(.*)}/,1], key, scale)
      notes = notes.concat(again)
    when '&' then
      # Recursive call from beginning to first !
      again = zparse(n.split('@')[0], key, scale)
      notes = notes.concat(again)
    else
      # Spaces, commas and all other nonsense
    end
    
    if dgr!=nil then
      note = nil
      if dgr==0 then
        note = :r
      else
        # Transpose if needed
        if dgr>scaleDegrees.length then
          note = degree(scaleDegrees[dgr],key,scale)
          note+=12
        else
          note = degree(dgr,key,scale)
        end
        # Add sharps and flats
        note = note + sfaddition
        sfaddition = 0
        # Add +- additions
        note = note + addition
      end
      # Add note to buffer if looping with :
      if loop && loopCount<1 then
        noteBuffer.push([note,noteLength*dotLength,vol, pan, slide])
      end
      # Push note and duration to list
      notes.push([note,noteLength*dotLength,vol, pan, slide])
      dot = 0
      dotLength = 1.0
    end
  end
  notes
end

def znotes(array)
  zindex(array,0)
end

def zsleeps(array)
  zindex(array,1)
end

def zindex(array, n)
  array = array.flatten
  (n...array.length).step(5).map { |i| array[i] }
end

def zloop(melody,key=:c, scale=:major,d=0.5, a=0.25)
  if melody.is_a? String then
    melody = zparse(melody,key, scale,d, a)
  end
  melody = melody.flatten.ring
  loop do
    note = melody.tick
    s = melody.tick
    a = melody.tick
    p = melody.tick
    slide = melody.tick
    c = play note, amp: (1+a < 0 ? 0 : 1+a), pan: p, note_slide: s, release: (slide ? s : 1)
    
    while slide do
        note = melody.tick
        s = melody.tick
        a = melody.tick
        p = melody.tick
        control c, note: note, amp: 1+a, pan: p
        slide = melody.tick
      end
      sleep s
    end
  end
  
  def zplay(melody,key=:c, scale=:major,d=0.5, a=0.25)
    if melody.is_a? String then
      melody = zparse(melody,key, scale,d, a)
    end
    n=0
    until n>=melody.length do
        note = melody[n][0]
        s = melody[n][1]
        a = melody[n][2]
        p = melody[n][3]
        slide = melody[n][4]
        c = play note, amp: (1+a < 0 ? 0 : 1+a), pan: p, note_slide: (slide ? s : 1), release: (slide ? s : 1)
        while slide && n+1<melody.length do
            n=n+1
            note = melody[n][0]
            s = melody[n][1]
            a = melody[n][2]
            p = melody[n][3]
            control c, note: note, amp: 1+a, pan: p
            slide = melody[n][4]
          end
          sleep s
          n=n+1
        end
      end
