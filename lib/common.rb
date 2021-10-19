module Ziffers
    module Common

      @@degree_based = false

      def set_degree_based(degrees=!@@degree_based)
        @@degree_based = degrees
      end

    # Gets note from degree. Degree can also be negative or overflow to next octave
    def get_note_from_dgr(dgr, zkey, zscale, zoct=nil)
      scaleLength = scale(zkey,zscale).length-1
      dgr = dgr + zoct*scaleLength if zoct
      dgr+=1 if dgr>=0 if !@@degree_based
      if dgr>=scaleLength || dgr<0 then
        oct = (dgr-1)/scaleLength*12
        dgr = dgr<0 ? (scaleLength+1)-(dgr.abs%scaleLength) : dgr%scaleLength
        return degree((dgr==0 ? scaleLength : dgr),zkey,zscale)+oct
      end
      return degree(dgr,zkey,zscale)
    end

    # Get ziff object from degree. Same as get_note_from_dgr but returns hash object
    def get_ziff(dgr, zkey=:C, zscale=:major, oct=0, addition=0)
      scaleLength = scale(zkey,zscale).length-1
      #dgr = dgr + zoct*scaleLength if zoct!=0
      dgr+=1 if dgr>=0 if !@@degree_based
      if dgr>=scaleLength || dgr<0 then
        oct += (dgr-1)/scaleLength
        dgr = dgr<0 ? (scaleLength+1)-(dgr.abs%scaleLength) : dgr%scaleLength
      end
      dgr = scaleLength if dgr == 0
      return {:note=>(degree(dgr,zkey,zscale)+(oct*12)+addition), :pc=>dgr-1, :key=>zkey, :scale=>zscale, :octave=>oct}
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

    # Pitch class interval
    def pc_int(a,b,mod=12) 6-2%12
      r = (b-a)%mod
      r+=mod if r<0
      r
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
