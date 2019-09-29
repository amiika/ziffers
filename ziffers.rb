print "Ziffers 1.0: See documentation for changes."

module Ziffers

  @@control_chars = {'A': :amp, 'C': :attack, 'P': :pan, 'D': :decay, 'S': :sustain, 'R': :release, 'Z': :sleep, 'X': :chord_sleep, 'I': :pitch,  'K': :key, 'L': :scale, '~': :note_slide, 'i': :chord, 'v': :chord, '%': :chord_invert, 'O': :channel, 'G': :arpeggio, "=": :eval }
  @@default_durs = {'m': 8.0, 'l': 4.0, 'd': 2.0, 'w': 1.0, 'h': 0.5, 'q': 0.25, 'e': 0.125, 's': 0.0625, 't': 0.03125, 'f': 0.015625, 'z': 0.0 }
  @@default_opts = { :key => :c, :scale => :major, :release => 1.0, :sleep => 1.0, :pitch => 0.0, :amp => 1, :pan => 0, :note_slide => 0.5, :skip => false, :pitch_slide => 0.25 }
  @@zero_based = false
  @@groups = false

  def get_default_opts
    @@default_opts
  end

  def set_default_opts(opts)
    @@default_opts.merge!(opts)
  end

  def self.set_default_sleep(sleep)
    @@default_sleep[:sleep] = sleep.to_f
  end

  def self.set_zero_based(bool)
    @@zero_based = bool
  end

  def self.is_zero_based
    @@zero_based
  end

  def self.set_groups(bool)
    @@groups = bool
  end

  def self.is_grouped
    @@groups
  end

  def self.durations
    @@default_durs
  end

  def merge_synth_defaults
    @@default_opts.merge!(Hash[current_synth_defaults.to_a])
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
def replace_random_syntax(n) # Replace random values inside [] and ()
  n = n.gsub(/\[(.*?)\]\*?(\d+)?/) do
    repeat = $2 ? $2.to_i : 1
    chooseArray = $1.split(",")
    result = ""
    repeat.times do
      result+=chooseArray.choose
    end
    result
  end
  n = replace_random_sequence(n)
  n
end

# Replaces random sequence syntax in a string
# Example: "(12,23) (1..3)*2" -> "19 123231"
# Random syntax and this method is work in progress and will change often
def replace_random_sequence(n)
  return n if !n.include?("(")
  # Debug: https://www.debuggex.com/r/1VusJWIiV_hRy3zt
  n = n.gsub(/\(((-?\d+)\.\.(\d+)|(-?\d+),(\d+)|(\.\.\d+))\)\+?(\d+)?(\?)?(\d+)?@?([1-9.\(\)\+\?]+)?(%[\w])?\^?([a-z]+)?\*?(\d+)?'?(.*?)'?/) do
    m = Regexp.last_match.captures
    resultArr=[]
    (m[12] ? m[12].to_i : 1).times do # *3
      nArr = m[5].chars.drop(2).map(&:to_i) if m[5] # (1234)
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
      nArr = nArr.inject(replace_random_sequence(m[9]).split("").map(&:to_i)) {|a,j| a.flat_map{|n|[n,n+j]}} if m[9] # @{4}
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

# Parses ziffers notation to Hash array
# Example "1 2"->[{degree:1, key: :c},{degree:2}] ... etc.
def zparse(n,opts={},shared={})
  notes, noteBuffer, controlBuffer, customChord, customChordDegrees, subList, sub = Array.new(7){ [] }
  loop, dc, ds, escape, quoted, skip, slideNext, negative = false, false, false, false, false, false, false, false
  stringFloat = ""
  dotLength = 1.0
  sfaddition, dot, loopCount, note = 0, 0, 0, 0, 0
  escapeType = nil
  midi = shared[:midi] ? true : false
  groups = (opts[:groups] ? opts.delete(:groups) : @@groups)
  if opts[:use] then
    use = opts.delete(:use) if opts[:use]
  else
    # Parse capital letters from the opts
    parsed_use = opts.select{|k,v| k.length<2 and /[[:upper:]]/.match(k)}
    use = parsed_use if !parsed_use.empty?
  end
  dgr_lengths = opts.delete(:lengths) if opts[:lengths]
  control_chars = @@control_chars.clone
  control_chars.except!(*use.keys) if use
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
            ziff[escapeType] = defaults.fetch(escapeType)
          elsif escapeType == :eval then
            dgr = eval(stringFloat)
          elsif escapeType == :scale || escapeType == :synth then
            ziff[escapeType] = search_list(escapeType == :scale ? scale_names : synth_names, stringFloat)
          elsif escapeType == :key then
            ziff[:key] = stringFloat.to_s
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
          elsif escapeType == :sleep then
            if stringFloat.include? "/" then
              sarr = stringFloat.split("/")
              noteLength = sarr[0].to_f/sarr[1].to_f
            else
              noteLength = stringFloat.to_f
            end
            ziff[:sleep] = noteLength
          elsif [:release,:sustain,:attack,:decay].include?(escapeType) then
            adsr[escapeType] = stringFloat.to_f
          else
            # ~ and something else?
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
      elsif use and use.key?(c.to_sym) then
        use_char = use[c.to_sym]
        raise ":run should be array of hashes" if use[:run] and !use[:run].kind_of?(Array)
        if (use_char.is_a? Hash) then
          if use_char[:note] then
            ziff[:port] = use_char[:port] if use_char[:port]
            ziff[:channel] = use_char[:channel] if use_char[:channel]
            #TODO: Merge use_char opts to clone of ziff instead?
            #ziffClone.merge use_char
            note = use_char[:note]
          elsif use_char[:sample]
            ziff[:sample_opts] = use_char
            ziff[:sample_opts][:run] = use[:run] if !use_char[:run] and use[:run]
          elsif use_char[:run]
            raise ":run should be array of hashes" if !use_char[:run].kind_of?(Array)
            ziff[:run] = use_char[:run]
          end
        else
          ziff[:sample_opts] = {sample: use_char} if use_char.is_a? Symbol
          ziff[:sample_opts][:run] = use[:run] if use[:run]
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
          ziff.delete(:run)
        when '.' then
          dot+=1
          dotLength = (2.0-(1.0/(2**dot))) # https://en.wikipedia.org/wiki/Dotted_note
        when "0" then
          if midi then
          stringFloat+=c
        elsif @@zero_based
          dgr = 0
        end
        when /^[1-9]+$/ then
          if midi then
            stringFloat+=c
          elsif next_c=='/' then
            escape = true
            escapeType = :sleep
            stringFloat = c
          elsif groups and next_c =~ /[0-9]/
            customChord.push(get_note_from_dgr(c.to_i,(ziff[:chord_key]!=nil ? ziff[:chord_key] : ziff[:key]),ziff[:scale])+sfaddition)
            customChordDegrees.push(c.to_i)
          elsif groups and customChord.length>0 and !(next_c =~ /[0-9]/)
            customChord.push(get_note_from_dgr(c.to_i,(ziff[:chord_key]!=nil ? ziff[:chord_key] : ziff[:key]),ziff[:scale])+sfaddition)
            customChordDegrees.push(c.to_i)
            ziff[:notes] = customChord
            ziff[:degrees] = customChordDegrees
            customChord=[]
            customChordDegrees=[]
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
          dgr = -(dgr)+ziff[:inverse]+(ziff[:offset] ? ziff[:offset] : 0) if ziff[:inverse] && dgr!=ziff[:inverse] && dgr!=0
          dgr = ((dgr+ziff[:offset])<=0) ? (dgr+ziff[:offset])-1 : dgr+ziff[:offset] if ziff[:offset]
          note = get_note_from_dgr(dgr, ziff[:key], ziff[:scale])
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
        sfaddition=0
      elsif ziff[:sample_opts]
        sample_opts = ziff.delete(:sample_opts)
        sampleZiff = ziff.clone
        sampleZiff.merge!(sample_opts)
        sampleZiff[:sleep] = (groups and next_c and use.key?(next_c.to_sym)) ?  0 : (noteLength*dotLength) if !sample_opts[:sleep]
        notes.push(sampleZiff)
        noteBuffer.push(sampleZiff) if loop && loopCount<1 # : buffer
        sub.push(sampleZiff) if sampleZiff[:sleep]>0 and subList.length>0
      end
      # Continues loop
    end
  end
  notes
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
# Degrees can also be zero based (0-T) which is useful for chromatic scale etc.
def get_note_from_dgr(dgr, zkey, zscale)
  dgr+=1 if @@zero_based and dgr>=0
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
  ziff.except(:rules,:eval,:gen,:arpeggio,:key,:scale,:chord_sleep,:chord_release,:chord_invert,:rate_based,:skip,:midi,:control,:degrees,:run,:sample)
end

def play_midi_out(md, opts)
  midi md, opts
end

def play_ziff(ziff,defaults={})
  if ziff[:skip] then
    print "Skipping note"
  elsif ziff[:notes] then
    if ziff[:arpeggio] then
      arp_opts = ziff.except(:key,:scale,:note,:notes,:arpeggio,:degree,:sleep)
      ziff[:arpeggio].each do |cn|
        if cn[:degrees] then
          arp_chord = cn[:degrees].map{|d| ziff[:notes][d-1]}
          arp_notes = {notes: arp_chord}
        else
          arp_notes = {note: ziff[:notes][cn[:degree]-1]}
        end
        arp_opts = cn.merge(arp_notes).except(:degrees)
        synth ziff[:chord_synth]!=nil ? ziff[:chord_synth] : current_synth, arp_opts if cn[:degree]!=0 && ziff[:port]==nil
        play_midi_out ziff[:notes][cn[:degree]-1]+cn[:pitch], {sustain: ziff[:chord_release], port: ziff[:port], channel: ziff[:channel]} if cn[:degree]!=0 && ziff[:port]
        sleep cn[:sleep]
      end
    else
      synth ziff[:chord_synth]!=nil ? ziff[:chord_synth] : current_synth, clean(ziff) if ziff[:port]==nil
      ziff[:notes].each { |cnote| play_midi_out(cnote, ziff[:chord_release],ziff[:port],ziff[:channel]) } if ziff[:port]
    end
  elsif ziff[:port] then
    sustain = ziff[:sustain]!=nil ? ziff[:sustain] :  ziff[:release]
    play_midi_out(ziff[:note]+ziff[:pitch], {sustain: sustain, port: ziff[:port], channel: ziff[:channel]})
  else
    slide = ziff.delete(:control)
    if ziff[:sample]!=nil then
      if defaults[:rate_based] && ziff[:note]!=nil then
        ziff[:rate] = pitch_to_ratio(ziff[:note]-note(ziff[:key]))
      elsif ziff[:degree]!=nil && ziff[:degree]!=0 then
        ziff[:pitch] = (scale 1, ziff[:scale], num_octaves: 2)[ziff[:degree]-1]+ziff[:pitch]-0.999
      end
      if ziff[:cut] then
        ziff[:finish] = [0.0,(ziff[:sleep]/(sample_duration (ziff[:sample_dir] ? [ziff[:sample_dir], ziff[:sample]] : ziff[:sample])))*ziff[:cut],1.0].sort[1]
        ziff[:finish]=ziff[:finish]+ziff[:start] if ziff[:start]
      end
      c = sample (ziff[:sample_dir] ? [ziff[:sample_dir], ziff[:sample]] : ziff[:sample]), clean(ziff)
    else
      if ziff[:synth] then
       c = synth ziff[:synth], clean(ziff)
      else
       c = play clean(ziff)
     end
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
  defaults.merge!(opts.extract!(:rate_based)) # Extract common options to defaults
  effects = opts.delete(:run) if opts[:run] # Get effects if any
  raise ":run should be array of hashes" if effects and !effects.kind_of?(Array)
  opts = get_default_opts.merge(opts)
  defaults[:preparsed] = true if !defaults[:parsed] and melody.is_a?(Array) and melody[0].is_a?(Hash)
  melody = normalize_melody(melody, opts, defaults) if !defaults[:parsed] and !defaults[:preparsed]
  if !opts[:port] and effects then
    block_with_effects effects.clone do
        zplayer(melody,opts,defaults)
      end
  else
    zplayer(melody,opts,defaults)
  end
end

def zplayer(melody,opts={},defaults={})
  melody.each do |ziff|
      ziff = opts.merge(merge_rate(ziff, defaults)) if defaults[:preparsed]
      if ziff[:run] then
        block_with_effects ziff[:run].clone do
          play_ziff(ziff,defaults)
        end
      else
        play_ziff(ziff,defaults)
      end
      sleep ziff[:sleep] if !ziff[:skip] and !(ziff[:notes] and ziff[:arpeggio])
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
      opts[:note] = get_note_from_dgr(@@zero_based ? melody : (melody==0 ? 1 : melody), opts[:key], opts[:scale])
    end
    set_ADSR(opts,@@default_opts.slice(:attack,:decay,:sustain,:release))
    return [opts]
  elsif melody.is_a?(Array)
      return zarray(melody,opts)
  else
    raise "Could not parse given melody!"
  end
end

def zloop(name, ziff, opts={}, defaults={})
  clean_loop_states # Clean loop states used with rules:
  $zloop_states.delete(name) if opts.delete(:reset)
  raise "First parameter should be loop name as a symbol!" if !name.is_a?(Symbol)
  raise "Third parameter should be options as hash object!" if !opts.kind_of?(Hash)
  if ziff.is_a?(Array) && ziff[0].is_a?(Hash) then
    defaults[:preparsed] = true
  elsif (ziff.is_a?(String) and !ziff.start_with? "//") and !opts[:seed]
      parsed_ziff = normalize_melody ziff, opts, defaults
      defaults[:parsed] = true
  end
  live_loop name, opts.slice(:init,:auto_cue,:delay,:sync,:sync_bpm,:seed) do
    if opts[:stop] or (ziff.is_a?(String) and ziff.start_with? "//")
      $zloop_states.delete(name)
      stop
    end
    if defaults[:preparsed] then
      zplay ziff, opts, defaults
    elsif parsed_ziff
      zplay parsed_ziff, opts.slice(:run), defaults
    else
      if opts[:rules] and !opts[:gen] then
        defaults[:lsystemloop] = true
        if !$zloop_states[name] then # If first time
          $zloop_states[name] = {}
          $zloop_states[name][:ziff] = ziff
          $zloop_states[name][:loop_i] = 0
        else # Get new state from rules
          $zloop_states[name][:loop_i] += 1
          $zloop_states[name][:ziff] = (lsystem($zloop_states[name][:ziff], opts[:rules], 1, $zloop_states[name][:loop_i]))[0]
        end
        zplay $zloop_states[name][:ziff], opts, defaults
      else
        zplay ziff, opts, defaults
      end
    end
  end
end

def clean_loop_states
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
  if x.length>0 then
    n = x.shift
    if n[:with_fx] then
      with_fx n[:with_fx], n do block_with_effects(x,&block) end
    elsif n[:with_swing]
      with_swing n[:with_swing], n do block_with_effects(x,&block) end
    elsif n[:with_bpm]
      with_bpm n[:with_bpm] do block_with_effects(x,&block) end
    elsif n[:with_cent_tuning]
      with_cent_tuning n[:with_cent_tuning] do block_with_effects(x,&block) end
    elsif n[:with_octave]
      with_octave n[:with_octave] do block_with_effects(x,&block) end
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
        if v.is_a? Proc
          if v.arity == 1 then
            v = v.(i).to_s
          elsif v.arity == 2
            regexp_lambda = true
            v = v.(i,g).to_s
          else
            v = v.().to_s
          end
        end
        if g[0] then
          rep = replace_random_syntax(replace_variable_syntax(v))
          if !regexp_lambda then
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
  n.chars.map { |c| noteList.index(c)!=nil ? noteList.index(c)+1 : c  }.join('')
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

                                     include Ziffers
