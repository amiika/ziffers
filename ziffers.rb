print "Ziffers 0.5: Octave syntax change - to _ and + to ^"

def defaultDurs
  durs = {'m': 8.0, 'l': 4.0, 'd': 2.0, 'w': 1.0, 'h': 0.5, 'q': 0.25, 'e': 0.125, 's': 0.0625, 't': 0.03125,'f': 0.015625, 'z': 0.0 }
end

def chordDefaults
  defaults = { :chordOctaves=>1, :chordSleep => 0, :chordRelease => 1, :chordInvert => 0, :sleep => 0 }
end

def defaultSampleOpts
  defaultSampleOpts = { :key => :c, :scale => :major, :sample => :ambi_piano, :rate => 1, :scale => :major, :pan => 0, :release => 0.0 }
end

def defaultOpts
  defaultOpts = { :key => :c, :scale => :major, :release => 1, :sleep => 0.25, :pitch => 0.0, :amp => 1, :pan => 0, :amp_step => 0.5, :note_slide => 0.5, :control => nil, :skip => false, :pitch_slide => 0.25, :offset => 0 }
  defaultOpts.merge(Hash[current_synth_defaults.to_a])
end

def controlChars
  controlChars = {'A': :amp, 'E': :env_curve, 'C': :attack, 'P': :pan, 'D': :decay, 'S': :sustain, 'R': :release, 'Z': :sleep, 'X': :chordSleep, 'T': :pitch,  'K': :key, 'L': :scale, '~': :note_slide, 'i': :chord, 'v': :chord, '%': :chordInvert, 'O': :channel, 'G': :arpeggio, 'N': :chordOctaves, "=": :eval }
end

def replaceRandomSyntax(n) # Replace random values inside [] and ()
  n.scan(/\(.*?\)/).each do |s|
    nlsp = s[1,s.length-2].split(";")
    revl = nlsp[0].split(",")
    lArr = nlsp[1].chars if nlsp[1]
    if revl.length > 3 then raise 'Too many parameters' end
    if (Integer(revl[0]) rescue false) then # (1,3) (1,3,2) (1,3,2;qe)
      lArr = lArr && lArr.length<revl[2].to_i ? lArr + Array.new(revl[2].to_i-lArr.length) {""} : lArr if lArr
      nArr = (revl.length==3 ? (Array.new(revl[2].to_i) {rrand_i(revl[0].to_i,revl[1].to_i)}) : rrand_i(revl[0].to_i, revl[1].to_i).to_s.chars)
      n = n.sub(s, (lArr ? lArr.zip(nArr) : nArr).join)
    elsif revl[0].include? ".." # (1..3) (1..3;qwe)
      sArr = revl[0].split("..")
      nArr = (sArr[0].to_i..sArr[1].to_i).to_a.shuffle
      nArr = (revl.length==2 ? nArr.take(revl[1].to_i) : nArr)
      lArr = lArr && lArr.length<nArr.length ? lArr + Array.new(nArr.length-lArr.length) {""} : lArr if lArr
      n = n.sub(s,(lArr ? lArr.zip(nArr) : nArr).join)
    else
      n = n.sub(s,(rrand revl[0].to_f, revl[1].to_f).to_s)
    end
  end
  n.scan(/\[.*?\]/).each do |s|
    n = n.sub(s,s[1,s.length-2].split(",").choose)
  end
  n
end

def zparse(n,opts={},shared={})
  notes, noteBuffer, controlBuffer, customChord = Array.new(4){ [] }
  loop, dc, ds, escape, skip, slideNext, negative = false, false, false, false, false, false, false
  stringFloat = ""
  noteLength, dotLength = 0.25, 1.0
  sfaddition, dot, loopCount, note = 0, 0, 0, 0, 0
  escapeType = nil
  midi = shared[:midi] ? true : false
  n = zpreparse(n,opts.delete(:parsekey)) if opts[:parsekey]!=nil
  n = lsystem(n,opts[:rules],opts[:gen])[opts[:gen]-1]
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
          elsif escapeType == :eval then
            dgr = eval(stringFloat)
          elsif escapeType == :scale || escapeType == :synth then
            ziff[escapeType] = searchList(escapeType == :scale ? scale_names : synth_names, stringFloat)
          elsif escapeType == :key then
            ziff[:key] = stringFloat.to_s
          elsif escapeType == :arpeggio then
            ziff[:arpeggio] = zparse stringFloat #stringFloat.each_char.map { |c| Integer(c) }
          elsif escapeType == :chordInvert || escapeType == :channel then
            ziff[escapeType] = stringFloat.to_i
          elsif escapeType == :chord then
            chordKey = (ziff[:chordKey] ? ziff[:chordKey] : ziff[:key])
            chordSets = chordDefaults.merge(ziff.clone)
            parsedChord = stringFloat.split("^")
            chordRoot = degree parsedChord[0].to_sym, chordKey, ziff[:scale]
            ziff[:chord] = chord_invert chord(chordRoot, parsedChord.length>1 ? parsedChord[1] : :major, num_octaves: chordSets[:chordOctaves]), chordSets[:chordInvert]
            if sfaddition > 0 then
              ziff[:chord] = ziff[:chord]+sfaddition
            end
          elsif escapeType == :sleep then
            if stringFloat.include? "/" then
              sarr = stringFloat.split("/")
              noteLength = sarr[0].to_f/sarr[1].to_f
            else
              noteLength = stringFloat.to_f
            end
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
      elsif escape && (["=",".","+","-","/","*","^"].include?(c) || c=~/^[a-zA-Z0-9]+$/) then
        stringFloat+=c
      else
        case c
        when '/' then
          if next_c=='/' then
            ziff[:skip]=!ziff[:skip]
          else
            stringFloat+=c
          end
        when '!' then
          # Reset node options to defaults
          addition = 0
          slideNext = false
          ziff = ziff.merge(defaults)
        when '.' then
          dot+=1
          dotLength = (2.0-(1.0/(2**dot))) # https://en.wikipedia.org/wiki/Dotted_note
        when /^[a-z]+$/ then
          noteLength = defaultDurs[c.to_sym]
        when /^[0-9]+$/ then
          if midi then
            stringFloat+=c
          elsif next_c=='/' then
            escape = true
            escapeType = :sleep
            stringFloat = c
          else
            dgr = c.to_i # Plain degrees 1234 etc.
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
        when '&' then
          sfaddition -= 1
        when '^' then
          ziff[:pitch] += 12
        when '_' then
          ziff[:pitch] -= 12
        when '-',"+"
          negative=!negative
        when '<' then
          ziff[:amp] = ziff.fetch(:amp)+ziff.fetch(:amp_step)
        when '>' then
          ziff[:amp] = ziff.fetch(:amp)-ziff.fetch(:amp_step)
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
        when '@' then # Recursive call from @ to @
          if ds then
            again = zparse(n[/\@(.*?)@/,1], defaults, shared.clone)
            notes = notes.concat(again)
          else
            ds = !ds
          end
        when '*' then # Recursive call from beginning to first *
          if dc then
            again = zparse(n.split('*')[0], defaults, shared.clone)
            notes = notes.concat(again)
          else
            dc = !dc
          end
        when '{' then
          escape = true
        when '}',',' then
          customChord.push(getNoteFromDgr(stringFloat.to_i,(ziff[:chordKey]!=nil ? ziff[:chordKey] : ziff[:key]),ziff[:scale])+sfaddition)
          stringFloat = ""
          if c =='}' then
            ziff[:chord] = customChord
            customChord=[]
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
          dgr = -(dgr)+ziff[:inverse]+ziff[:offset] if ziff[:inverse] && dgr!=ziff[:inverse] && dgr!=0
          dgr = ((dgr+ziff[:offset])<=0) ? (dgr+ziff[:offset])-1 : dgr+ziff[:offset]
          note = getNoteFromDgr(dgr, ziff[:key], ziff[:scale])
        end
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
            controlZiff = controlZiff.except(:attack,:release,:sustain,:decay)
          end
          ziff[:degree] = dgr
          ziff[:note] = note
          ziff[:sleep] = noteLength*dotLength
          ziff[:sustain] = defaults[:sustain]*(ziff[:sleep]==0 ? 1 : ziff[:sleep]*2) if ziff[:sustain]!=nil
          ziff[:release] = defaults[:release]*(ziff[:sleep]==0 ? 1 : ziff[:sleep]*2)
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
        sfaddition=0
      end
      # Continues loop
    end
  end
  notes
end

def getNoteFromDgr(dgr, zkey, zscale)
  return :r if dgr==0
  scaleLength = scale(zkey,zscale).length-1
  if dgr>=scaleLength || dgr<0 then
    oct = (dgr-1)/scaleLength*12
    dgr = dgr<0 ? (scaleLength+1)-(dgr.abs%scaleLength) : dgr%scaleLength
    return degree(dgr==0 ? scaleLength : dgr,zkey,zscale)+oct
  end
  return degree(dgr,zkey,zscale)
end

def searchList(arr,query)
  result = (Float(query) != nil rescue false) ? arr[query.to_i] : arr.find { |e| e.match( /\A#{Regexp.quote(query)}/)}
    return (result == nil ? query : result)
  end
  
  def mergeRates(ziff, opts)
    ziff.merge(opts) {|_,a,b| (a.is_a? Numeric) ? a * b : b }
  end
  
  def zparams(hash, name)
    hash.map{|x| x[name]}
  end
  
  def clean(ziff)
    ziff.except(:rules, :eval, :gen, :arpeggio, :key,:scale,:chordSleep,:chordRelease,:chordInvert,:ampStep,:rateBased,:skip,:midi,:control)
  end
  
  def playMidiOut(md, ms, p, c)
    midi md, {sustain: ms, port: p }.tap { |hash| hash[:channel] = c if c!=nil }
  end
  
  def playZiff(ziff,defaults={})
    if ziff[:skip] then
      print "Skipping note"
    elsif ziff[:chord] then
      if ziff[:arpeggio] then
        ziff[:arpeggio].each { |cn|
          synth ziff[:chordSynth]!=nil ? ziff[:chordSynth] : current_synth, note: ziff[:chord][cn[:degree]-1], amp: ziff[:amp], pan: ziff[:pan], attack: ziff[:attack], release: ziff[:release], sustain: ziff[:sustain], decay: ziff[:decay], pitch: cn[:pitch] if cn[:degree]!=0 && ziff[:port]==nil
          playMidiOut(ziff[:chord][cn[:degree]-1]+cn[:pitch], ziff[:chordRelease], ziff[:port],ziff[:channel]) if cn[:degree]!=0 && ziff[:port]
        sleep cn[:sleep] }
      else
        synth ziff[:chordSynth]!=nil ? ziff[:chordSynth] : current_synth, notes: ziff[:chord], amp: ziff[:amp], pan: ziff[:pan], attack: ziff[:attack], release: ziff[:release], sustain: ziff[:sustain], decay: ziff[:decay], pitch: ziff[:pitch], note_slide: ziff[:note_slide] if ziff[:port]==nil
        ziff[:chord].each { |cnote| playMidiOut(cnote, ziff[:chordRelease],ziff[:port],ziff[:channel]) } if ziff[:port]
      end
    elsif ziff[:port] then
      sustain = ziff[:sustain]!=nil ? ziff[:sustain] :  ziff[:release]
      playMidiOut(ziff[:note]+ziff[:pitch],sustain, ziff[:port], ziff[:channel])
    else
      slide = ziff.delete(:control)
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
          cziff[:pitch] = (scale 1, cziff[:scale])[cziff[:degree]-1]+cziff[:pitch]-0.999 if cziff[:sample]!=nil && cziff[:degree]!=nil && cziff[:degree]!=0
          control c, clean(cziff)
          sleep cziff[:sleep]
        end
      end
    end
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
      raise "Use zarray to parse degree arrays to hash array" if (melody.is_a? Array) && !(melody[0].is_a? Hash)
      if melody.is_a? String then
        melody = zparse(melody,opts,defaults)
        defaults[:parsed]==true
      end
      melody.each_with_index do |ziff,index|
        ziff = mergeRates(ziff, defaults) if defaults[:parsed]==nil
        playZiff(ziff,defaults)
        sleep ziff[:sleep] if !ziff[:skip] and !(ziff[:chord] and ziff[:arpeggio])
      end
    end
  end