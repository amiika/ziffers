module Ziffers
    module Common
    include Ziffers::Defaults
      @@degree_based = false

      def set_degree_based(degrees=!@@degree_based)
        @@degree_based = degrees
      end

    def get_note_from_dgr(dgr, zkey, zscale, oct=0, add=0)
      ziff = get_ziff(dgr,zkey,zscale,oct,add)
      ziff[:note]
    end

    def get_ziff_chord(dgrs, zkey, zscale, oct=0, add=0)
      if dgrs.is_a?(Array)
        dgr_list = dgrs.map{|dval| split_int_to_string_array(dval) }.flatten.compact
      else
        dgr_list = split_int_to_string_array(dgrs)
      end
      ziffs = dgr_list.each.collect {|d| h = get_ziff(d.to_i,zkey,zscale,false,add) }
      ZiffHash[{hpcs: ziffs, key: zkey, scale: zscale}]
    end

    def split_int_to_string_array(dgrs)
      dgr_list= dgrs.to_s.split("")
      if dgr_list[0] == "-"
        dgr_list = dgr_list[1..]
        dgr_list[0] = "-"+dgr_list[0]
      end
      dgr_list
    end

    # Get ziff object from degree. Same as get_note_from_dgr but returns hash object
    def get_ziff(dgr, zkey=:C, zscale=:major, oct=0, addition=0, semitones=1)
      if !oct.is_a?(Integer) # Ignore octave. Used by generative parser
        oct = 0
        no_octaves = true
      end
      pc_orig = dgr
      if dgr.is_a?(Float)
        split_dgr = dgr.divmod 1
        remainder = split_dgr[1]
        dgr = split_dgr[0]
      end
      return {:note=>:r} if dgr==0 and @@degree_based
      used_scale = scale(0,zscale)
      scaleLength = used_scale.length-1
      dgr+=1 if dgr>=0 and !@@degree_based
      if dgr>=scaleLength || dgr<0 then
        oct += (dgr-1)/scaleLength
        dgr = dgr<0 ? (scaleLength+1)-(dgr.abs%scaleLength) : dgr%scaleLength
      end
      dgr = scaleLength if dgr == 0
      note_value = (degree(dgr,zkey,zscale)+(oct*used_scale[-1])+addition)

      if remainder
        rounded_pc = (pc_orig+(!@@degree_based ? 1.0 : 0.0)).round
        orig_value = (degree(rounded_pc,zkey,zscale)+(oct*used_scale[-1])+addition)
        note_value = note_value.to_f + (rounded_pc==dgr ? rounded_pc*remainder : ((orig_value-note_value)*remainder))
      end

      if note_value.kind_of?(Float) and note_value.modulo(1)!=0.0
        start_value = note_value > note_value.round ? note_value : note_value.round
        end_value = note_value > note_value.round ? note_value.round : note_value
        bend_diff = midi_to_hz(start_value) / midi_to_hz(end_value)
        bend_target = 1200 * Math.log2(bend_diff)
        # http://hyperphysics.phy-astr.gsu.edu/hbase/Music/cents.html
        # https://www.cs.cmu.edu/~rbd/doc/cmt/part7.html
        begin
          midi_bend_value = 8192 + (8191 * (bend_target/(100*semitones))).to_i
        rescue FloatDomainError
          midi_bed_value = 8192
        end
      end

      ziff = ZiffHash[{:note=>note_value>0 ? (note_value>231 ? 230 : note_value) : 0, :pc=>dgr-1, :pc_orig=>pc_orig, :key=>zkey, :scale=>zscale, :octave=>oct, :scale_length=>scaleLength, :add=>addition}]
      if no_octaves # Ignore octave, used by generative parser
        ziff[:pc] = pc_orig
        ziff.delete(:octave)
      end
      ziff[:delta_midi] = midi_bend_value if midi_bend_value
      return ziff
    end

    # Scales degrees to scale, for example -1=7 and 8=1
    def get_real_dgr(dgr,zkey,zscale)
      scaleLength = scale(zkey,zscale).length-1
      return dgr<0 ? (scaleLength)-(dgr.abs%scaleLength) : dgr%scaleLength
    end

    def parse_str_dgr(dgr)
      case dgr
      when "E"
        return 11
      when "T"
        return 10
      when "-E"
        return -11
      when "-T"
        return -10
      else
        return dgr.to_i
      end
    end

    # Adapted from: https://github.com/beausievers/Ruby-PCSet/blob/master/pcset.rb#L339
    def most_left_compact(pcset_array)
      if !pcset_array.all? {|pcs| pcs.length == pcset_array[0].length}
        raise ArgumentError, "All PCSets must be of same cardinality", caller
      end
      zeroed_pitch_arrays = pcset_array.map {|pcs| pcs.zero.pcs}
      binaries = zeroed_pitch_arrays.map {|array| array.inject(0) {|sum, n| sum + 2**n}}
      winners = []
      binaries.each_with_index do |num, i|
        if num == binaries.min then winners.push(pcset_array[i]) end
      end
      winners.sort[0]
    end

    # Pitch class interval
    def pc_int(a,b,mod=12)
      r = (b-a)%mod
      r+=mod if r<0
      r
    end

    def pc_intervals(pcs)
      (pcs.length-1).times.collect {|i|
        pc_int(pcs[i], pcs[i+1])
      }
    end

    def get_key_name(input)
      key_name = (note_info input).pitch_class # 61=:Cs by default in Sonic Pi
      key_name
    end

    # Accidentals as range from -7 to 7
    def accidentals(input) # Integer or symbol
      key_name = get_key_name(input)
      circle_of_fifths = [:Gb,:Cs,:Ab,:Eb,:Bb,:F,:C,:G,:D,:A,:E,:B,:Fs]
      idx = circle_of_fifths.index(key_name)
      idx-6
    end

    # See: https://github.com/musescore/MuseScore/blob/master/doc/tpc.md
    def midi_to_tpc(pitch, acc)
      acc = accidentals acc if !acc.is_a?(Integer)
      (pitch * 7 + 26 - (11 + acc)) % 12 + (11 + acc)
    end

    # Midi to names pitch class
    def midi_to_pc(cnc, key, zscale)
      sharps = ["0", "#0", "1", "#1", "2", "3", "#3", "4", "#4", "5", "#5", "6"]
      flats = ["0", "b1", "1", "b2", "2", "3", "b4", "4", "b5", "5", "b6", "6"]
      tpc = midi_to_tpc cnc, key
      pc = note_pc(cnc) # - acc?
      oct = (note_oct (cnc)) - 5
      return ZiffHash[{octave: oct, pc: pc, key: key, scale: zscale, note: cnc}] if zscale==:chromatic
      if (tpc >= 6 && tpc <= 12 && flats[pc].length == 2)
        npc = flats[pc]
      elsif (tpc >= 20 && tpc <= 26 && flats[pc].length == 2)
        npc = sharps[pc]
      else
        npc = sharps[pc]
      end
      v = {octave: oct, pc: (npc.length>1 ? npc[1] : npc).to_i, key: key, scale: zscale, note: cnc}
      v[:add] = (npc[0]=="#" ? 1 : -1) if npc.length>1
      ZiffHash[v]
    end

    # Inversed pitch class interval
    def pc_int_inv(a,mod=12)
      return (12-a)%mod
    end

    # Pitch class from note
    def note_pc(note)
      note % 12
    end

    # Octave from note
    def note_oct(note)
      return 0 if note<=0
      note / 12
    end

    # Interval class
    def pc_int_pic(pc_int,mod=12)
      pc_int <= 6 ? pc_int : mod-pc_int
    end

    # Pitch class transposition
    def pc_transpose(pc,pc_int,mod=12)
      (pc+pc_int)%12
    end

    # Pitch class to continuous name code
    # By default pc to midi (mod 12)
    def pc_to_cnc(nc, oct, mod=12)
      (oct*mod)+nc
    end

  end
end
