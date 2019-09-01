print "Ziffers 0.8: Changed '0' to 'r'. Added option for zero-based notation + new features / changes in random sequences."

module Ziffers

  @@controlChars = {'A': :amp, 'C': :attack, 'P': :pan, 'D': :decay, 'S': :sustain, 'R': :release, 'Z': :sleep, 'X': :chord_sleep, 'I': :pitch,  'K': :key, 'L': :scale, '~': :note_slide, 'i': :chord, 'v': :chord, '%': :chord_invert, 'O': :channel, 'G': :arpeggio, 'N': :chord_octaves, "=": :eval }
  @@chordDefaults = { :chord_octaves=>1, :chord_sleep => 0, :chord_release => 1, :chord_invert => 0, :sleep => 0, :chord_name => :major }
  @@defaultDurs = {'m': 8.0, 'l': 4.0, 'd': 2.0, 'w': 1.0, 'h': 0.5, 'q': 0.25, 'e': 0.125, 's': 0.0625, 't': 0.03125, 'f': 0.015625, 'z': 0.0 }
  @@defaultOpts = { :key => :c, :scale => :major, :release => 1, :sleep => 0.25, :pitch => 0.0, :amp => 1, :pan => 0, :amp_step => 0.5, :note_slide => 0.5, :control => nil, :skip => false, :pitch_slide => 0.25 }
  @@zero_based = false
  @@simultanious = false

  def self.setZeroBased(bool)
    @@zero_based = bool
  end

  def self.isZeroBased
    @@zero_based
  end

  def self.setSimultanious(bool)
    @@simultanious = bool
  end

  def self.isSimultanious
    @@simultanious
  end

  def self.durations
    @@defaultDurs
  end

  def removeControlChars(keys)
    @@controlChars = @@controlChars.except(*keys)
  end

def getDefaultOpts
  @@defaultOpts.merge(Hash[current_synth_defaults.to_a])
end

def replaceVariableSyntax(n,rep={})
  n = n.gsub(/\<(.)=(.*?)\>/) do
    rep[$1] = replaceRandomSyntax($2)
    ""
  end
  rep.each { |k,v| n.gsub!(/#{Regexp.escape(k)}/,v) }
  n
end

def replaceRandomSyntax(n) # Replace random values inside [] and ()
  n = n.gsub(/\[(.*?)\]\*?(\d+)?/) do
    repeat = $2 ? $2.to_i : 1
    chooseArray = $1.split(",")
    result = ""
    repeat.times do
      result+=chooseArray.choose
    end
    result
  end
  n = replaceRandomSequence(n)
  n
end

def replaceRandomSequence(n)
  return n if !n.include?("(")
  # Debug: https://www.debuggex.com/r/1VusJWIiV_hRy3zt
n = n.gsub(/\(((-?\d+)\.\.(\d+)|(-?\d+),(\d+)|(\d+))\)\+?(\d+)?(\?)?(\d+)?@?([1-9.\(\)\+\?]+)?(%[\w])?\^?([a-z]+)?\*?(\d+)?'?(.*?)'?/) do
    m = Regexp.last_match.captures
    resultArr=[]
    (m[12] ? m[12].to_i : 1).times do # *3
      nArr = m[5].chars.map(&:to_i) if m[5] # (1234)
      if m[1] && m[2] then # 1..7 +2
        s = m[1].to_i
        e = m[2].to_i
        ms = s>e ? e : s # 1..7
        me = e>s ? e : s # 7..1
        nArr = (m[6] ? (ms..me).step(m[6].to_i).to_a : (ms..me).to_a) - [0]
        nArr = nArr.reverse if s>e
      end
      nArr = rrand_i(m[3].to_i,m[4].to_i).to_s.chars if m[3] && m[4] # 1,3
      nArr = nArr.shuffle if m[7] # ?
      nArr = nArr.take(m[8].to_i) if m[8] # ?3
      nArr = nArr.inject(replaceRandomSequence(m[9]).split("").map(&:to_i)) {|a,j| a.flat_map{|n|[n,n+j]}} if m[9] # @{4}
      nArr = nArr + (m[10]=="%s" ? nArr.drop(1).reverse.drop(1) : m[10]=="%r" ? nArr.reverse.drop(1) : nArr.reverse) if m[10] # %
      nArr = nArr.join("").split("")
      lArr = m[11].chars if m[11] #^qwe
      nArr = (lArr.length<nArr.length ? lArr*(nArr.length/lArr.length) : lArr).zip(nArr) if lArr
      resultArr += nArr
    end
    m[13] ? resultArr.join(m[13]) : resultArr.join
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
  simultanious = opts[:simultanious] ? opts[:simultanious] : @@simultanious
  samples = opts.delete(:samples) if opts[:samples]
  dgrLengths = opts.delete(:lengths) if opts[:lengths]
  removeControlChars(samples.keys) if samples
  n = zpreparse(n,opts.delete(:parsekey)) if opts[:parsekey]!=nil
  n = lsystem(n,opts[:rules],opts[:gen])[opts[:gen]-1] if opts[:rules]
  defaults = getDefaultOpts.merge(opts)
  ziff, controlZiff = defaults.clone # Clone defaults to preliminary Hash objects
  n = replaceVariableSyntax(n)
  n = replaceRandomSyntax(n)
  print "Ziffers: "+n
  chars = n.chars # Loop chars
  chars.to_enum.each_with_index do |c, index|
    next_c = chars[index+1]
    dgr = nil
    if skip then
      skip = false # Skip next char and continue
    else
      if !escape && @@controlChars.key?(c.to_sym) then
        escapeType = @@controlChars[c.to_sym]
        escape = true
        if @@controlChars[c.to_sym] == :chord then
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
          elsif escapeType == :chord_invert || escapeType == :channel then
            ziff[escapeType] = stringFloat.to_i
          elsif escapeType == :chord then
            chord_key = (ziff[:chord_key] ? ziff[:chord_key] : ziff[:key])
            chordSets = @@chordDefaults.merge(ziff.clone)
            parsedChord = stringFloat.split("^")
            chordRoot = degree parsedChord[0].to_sym, chord_key, ziff[:scale]
            ziff[:chord] = chord_invert chord(chordRoot, parsedChord.length>1 ? parsedChord[1] : chordSets[:chord_name], num_octaves: chordSets[:chord_octaves]), chordSets[:chord_invert]
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
      elsif samples and samples.key?(c.to_sym) then
        sample = samples[c.to_sym]
        sample_opts = (sample.is_a? Hash) ? sample[:opts] : nil
        sample = sample[:sample] if (sample.is_a? Hash)
        ziff[:playSample] = sample
        ziff[:sampleOpts] = sample_opts
      elsif @@defaultDurs.key?(c.to_sym) then
        noteLength = @@defaultDurs[c.to_sym]
      else
        case c
        when 'T' then
          dgr = 10
        when 'E' then
          dgr = 11
        when 'r' then
          note = :r
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
        when "0" then
          if midi then
          stringFloat+=c
        else
          dgr = 0 if @@zero_based
        end
        when /^[1-9]+$/ then
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
        when '-'
          negative=true
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
            notes = notes.concat(zparse(n.split('*')[0], defaults, shared.clone))
          else
            dc = !dc
          end
        when '{' then
          escape = true
        when '}',',' then
          customChord.push(getNoteFromDgr(stringFloat.to_i,(ziff[:chord_key]!=nil ? ziff[:chord_key] : ziff[:key]),ziff[:scale])+sfaddition)
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
          dgr = -(dgr)+ziff[:inverse]+(ziff[:offset] ? ziff[:offset] : 0) if ziff[:inverse] && dgr!=ziff[:inverse] && dgr!=0
          dgr = ((dgr+ziff[:offset])<=0) ? (dgr+ziff[:offset])-1 : dgr+ziff[:offset] if ziff[:offset]
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
          if dgrLengths then
            dgrLength = dgrLengths[dgr] # Try -1 or 9 etc. otherwise try with real degrees
            dgrLength = dgrLengths[getRealDegree(dgr,ziff[:key], ziff[:scale])] if !dgrLength
          end
          if simultanious and (next_c =~ /[0-9]/ or (samples and next_c and samples.key?(next_c.to_sym)))
              ziff[:sleep] = 0
            else
              if dgrLength then
                ziff[:sleep] = (dgrLength.is_a?(String) ? @@defaultDurs[dgrLength.to_sym] : dgrLength)*dotLength
              else
              ziff[:sleep] = noteLength*dotLength
            end
          end
          ziff[:sustain] = ziff[:sustain]*(ziff[:sleep]==0 ? 1 : ziff[:sleep]*2) if ziff[:sustain]!=nil
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
        negative=false
        dotLength = 1.0
        note = 0
      elsif ziff[:chord]!=nil
        chordZiff = @@chordDefaults.merge(ziff.clone)
        chordZiff[:sleep] = chordZiff[:chordLength] ? noteLength : chordZiff.delete(:chord_sleep)
        chordZiff[:release] = chordZiff[:chordLength] ? noteLength : ziff[:chord_release]
        notes.push(chordZiff)
        noteBuffer.push(chordZiff.clone) if loop && loopCount<1 # : buffer
        ziff.delete(:chord)
        sfaddition=0
      elsif ziff[:playSample]!=nil
        sampleZiff = ziff.clone
        sampleZiff[:sleep] = (ziff[:sampleOpts] and ziff[:sampleOpts][:sleep])  ? ziff[:sampleOpts][:sleep] : ((simultanious and next_c and samples.key?(next_c.to_sym)) ?  0 : noteLength*dotLength)
        print noteLength*dotLength
        notes.push(sampleZiff)
        noteBuffer.push(sampleZiff.clone) if loop && loopCount<1 # : buffer
        ziff.delete(:playSample)
        ziff.delete(:sampleOpts)
      end
      # Continues loop
    end
  end
  notes
end

def getRealDegree(dgr,zkey,zscale)
  scaleLength = scale(zkey,zscale).length-1
  return dgr<0 ? (scaleLength+1)-(dgr.abs%scaleLength) : dgr%scaleLength
end

def getNoteFromDgr(dgr, zkey, zscale)
  dgr+=1 if @@zero_based and dgr>=0
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
    (result == nil ? query : result)
  end

  def zparams(hash, name)
    hash.map{|x| x[name]}
  end

  def clean(ziff)
    ziff.except(:rules, :eval, :gen, :arpeggio, :key,:scale,:chord_sleep,:chord_release,:chord_invert,:ampStep,:rate_based,:skip,:midi,:control)
  end

  def playMidiOut(md, opts)
    midi md, opts
  end

  def playZiff(ziff,defaults={})
    if ziff[:skip] then
      print "Skipping note"
    elsif ziff[:playSample] then
      sample ziff[:playSample], ziff[:sampleOpts]
    elsif ziff[:chord] then
      if ziff[:arpeggio] then
        ziff[:arpeggio].each { |cn|
          synth ziff[:chord_synth]!=nil ? ziff[:chord_synth] : current_synth, note: ziff[:chord][cn[:degree]-1], amp: ziff[:amp], pan: ziff[:pan], attack: ziff[:attack], release: ziff[:release], sustain: ziff[:sustain], decay: ziff[:decay], pitch: cn[:pitch] if cn[:degree]!=0 && ziff[:port]==nil
          playMidiOut ziff[:chord][cn[:degree]-1]+cn[:pitch], {sustain: ziff[:chord_release], port: ziff[:port], channel: ziff[:channel]} if cn[:degree]!=0 && ziff[:port]
        sleep cn[:sleep] }
      else
        synth ziff[:chord_synth]!=nil ? ziff[:chord_synth] : current_synth, notes: ziff[:chord], amp: ziff[:amp], pan: ziff[:pan], attack: ziff[:attack], release: ziff[:release], sustain: ziff[:sustain], decay: ziff[:decay], pitch: ziff[:pitch], note_slide: ziff[:note_slide] if ziff[:port]==nil
        ziff[:chord].each { |cnote| playMidiOut(cnote, ziff[:chord_release],ziff[:port],ziff[:channel]) } if ziff[:port]
      end
    elsif ziff[:port] then
      sustain = ziff[:sustain]!=nil ? ziff[:sustain] :  ziff[:release]
      playMidiOut(ziff[:note]+ziff[:pitch], {sustain: sustain, port: ziff[:port], channel: ziff[:channel]})
    else
      slide = ziff.delete(:control)
      if ziff[:sample]!=nil then
        if defaults[:rate_based] && ziff[:note]!=nil then
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
    shared[:rate_based] = true if opts[:sample] && shared[:degreeBased]!=nil
    opts[:degree] = melody-opts[:key] if shared[:degreeBased]
    zplay(melody,opts,shared)
  end

  def zplay(melody,opts={},defaults={})
    opts = getDefaultOpts.merge(opts)
    if melody.is_a? Numeric then # zplay 1 OR zmidi 85
      if defaults[:midi] then
        opts[:note] = melody
      else
        opts[:note] = getNoteFromDgr(@@zero_based ? melody : (melody==0 ? 1 : melody), opts[:key], opts[:scale])
      end
      playZiff(opts,defaults)
    else
      if (melody.is_a? Array) && !(melody[0].is_a? Hash) then
        melody = zarray(melody,opts)
      end
      if melody.is_a? String then
        melody = zparse(melody,opts,defaults)
        defaults[:parsed]==true
      end
      melody.each do |ziff|
        ziff = opts.merge(mergeRates(ziff, defaults)) if defaults[:parsed]==nil
        playZiff(ziff,defaults)
        sleep ziff[:sleep] if !ziff[:skip] and !(ziff[:chord] and ziff[:arpeggio])
      end
    end
  end

  def mergeRates(ziff, opts)
    ziff.merge(opts) {|_,a,b| (a.is_a? Numeric) ? a * b : b }
  end

  def lsystem(ax,rules,gen)
    gen.times.collect.with_index do |i|
      ax = rules.each_with_object(ax.dup) do |(k,v),s|
        v = v[i] if (v.is_a? Array or v.is_a? SonicPi::Core::RingVector) # [nil,"1"].ring -> every other
        prob = v.match(/([0-9]*\.?[0-9]+)%=(.+)/) if v
        v = prob[2] if prob
        if v then
         s.gsub!(/{{.*?}}|(#{k.is_a?(String) ? Regexp.escape(k) : k})/) do |m|
           g = Regexp.last_match.captures
           if g[0] && (prob==nil || (prob && (rand < prob[1].to_f))) then
            rep = replaceRandomSyntax(replaceVariableSyntax(v))
            rep = g.length>1 ? rep.gsub(/\$([1-9])/) {g[Regexp.last_match[1].to_i]} : rep.gsub("$",m)
            rep = rep.include?("'") ? rep.gsub(/'(.*?)'/) {eval($1)} : rep
            "{{#{rep}}}" # Escape
          else
            m # If escaped or rand<prob
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
    n.chars.map { |c| noteList.index(c)!=nil ? noteList.index(c)+1 : c  }.join('')
  end

  def zarray(arr, opts=getDefaultOpts)
    zmel=[]
    arr.each do |item|
      if item.is_a? Array then
        zmel.push arrayToHash(item,opts)
      elsif item.is_a? Numeric then
        if item!=0 then
        opts[:note] = getNoteFromDgr(item, opts[:key], opts[:scale])
        zmel.push(opts.clone)
      end
      end
    end
    zmel
  end

  def arrayToHash(obj,opts=getDefaultOpts)
    defObj = [0,opts[:sleep],opts[:key],opts[:scale],opts[:release]]
    arrayOpts = [:note,:sleep,:key,:scale,:release]
    obj.each_with_index { |item,index| defObj[index] = item }
    defObj[0] = getNoteFromDgr(defObj[0], defObj[2], defObj[3])
    opts.merge(Hash[arrayOpts.zip(defObj)])
  end

  def zbeats(arr)
    zparams(arr,:sleep).inject(0){|sum,x| sum+x }
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
end

include Ziffers
