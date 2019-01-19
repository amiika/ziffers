# Requires ziffers.rb to run

def lsystem(ax,rules,gen)
  gen.times.collect do
    ax = rules.each_with_object(ax.dup) do |(k,v),s|
      prob = v.match(/([-+]?[0-9]*\.?[0-9]+)%=(.+)/)
      v = prob[2] if prob
      s.gsub!(/{{.*?}}|(#{k.is_a?(String) ? Regexp.escape(k) : k})/) do |m|
        g = Regexp.last_match.captures
        if g[0] && (prob==nil || (prob && (rand < prob[1].to_f))) then
          rep = g.length>1 ? v.gsub(/\$([1-9])/) {g[Regexp.last_match[1].to_i]} : v.gsub("$",m)
          rep = replaceRandomSyntax(rep.include?("'") ? rep.gsub(/'(.*?)'/) {eval($1)} : rep)
          "{{#{rep}}}" # Escape
        else
          m # If escaped or rand<prob
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

def zbin(melody,opts={},defaults={})
  zAlt(melody,opts,defaults)
end

def zharmony(melody,opts={},defaults={})
  zAlt(melody,opts,defaults)
end

def zAlt(melody,opts={},defaults={})
  opts = defaultOpts.merge(opts)
  if melody.is_a? Numeric then
    if defaults[:midi] then
      opts[:note] = melody
    else
      opts[:note] = getNoteFromDgr(melody, opts[:key], opts[:scale])
    end
    playBin(opts,defaults)
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
      playBin(ziff,defaults)
      sleep ziff[:sleep] if !ziff[:skip]
    end
  end
end

def playBin(ziff,defaults={})
  if ziff[:skip] then
    print "Skipping note"
  elsif ziff.has_key?(:chord) then
    synth ziff[:chordSynth]!=nil ? ziff[:chordSynth] : current_synth, notes: ziff[:chord], amp: ziff[:amp], pan: ziff[:pan], attack: ziff[:attack], release: ziff[:release], sustain: ziff[:sustain], decay: ziff[:decay], pitch: ziff[:pitch], note_slide: ziff[:note_slide]
  else
    if ziff[:hz]!=nil then
      ziff[:pan] = ziff[:pan]==0 ? 1 : ziff[:pan]
      bziff = binauralDegree(ziff,defaults)
      if bziff[:sample]!=nil then
        bnote = sample bziff[:sample], clean(bziff)
      else
        bnote = play clean(bziff)
      end
    elsif ziff[:harmony]!=nil then
      hziff = harmonyDegree(ziff,defaults)
      hnote = play clean(hziff)
    end
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
        if cziff[:hz]!=nil then
          cziff[:pan] = cziff[:pan]==0 ? 1 : cziff[:pan]
          bziff = binauralDegree(cziff,defaults)
          control bnote, clean(bziff)
        elsif ziff[:harmony]!=nil then
          hziff = harmonyDegree(ziff,defaults)
          control hnote, clean(hziff)
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

def harmonyDegree(hziff,defaults={})
  ziff = hziff.clone
  ziff[:degree] = ziff[:harmony]!=nil ? ((ziff[:degree]+(ziff[:harmony])<=0) ? ziff[:degree]+ziff[:harmony]-1 : ziff[:degree]+ziff[:harmony]) : ziff[:degree]
  ziff[:note] = getNoteFromDgr(ziff[:degree],ziff[:key],ziff[:scale])
  return ziff
end

