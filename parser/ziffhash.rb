module Ziffers
  class ZiffHash < Hash

      def eql?(other_hash)
        @@set_keys.filter {|key| self[key] == other_hash[key]} == @@set_keys
      end

      # TODO: Add other keys to hash?
      def hash
          self[:degree].hash
      end

      def pc
        self[:degree]
      end

      def note
        self[:note]
      end

      def deep_clone
        ZiffHash[Marshal.load(Marshal.dump(self))]
      end

      def pitch_class
        self[:degree]
      end

      def minus val
        self[:degree]-=val
      end

      def plus val
        self[:degree]+=val
      end

      def multiply val
        self[:degree]*=val
      end

      def transpose(i, inv=false)
        ziff = self.deep_clone
        n = scale(ziff[:key], ziff[:scale]).length-1
        if ziff[:degrees]
          ziff[:degrees].each_with_index do |originalDegree, index|
            val = inv ? i-originalDegree : originalDegree+i
            ziff[:octave] += val/n if val>=n or val<0
            val = val % n
            ziff[:degrees][index] = val
            ziff.update_note
          end
        elsif ziff[:degree]
          originalDegree = ziff[:degree]
          val = inv ? i-originalDegree : originalDegree+i
          ziff[:octave] += val/n if val>=n or val<0
          val = val % n
          ziff[:degree] = val
          ziff.update_note
        end
        ziff
      end

      def update_note
        if self[:degree]
          self[:note] = get_note_from_dgr(self[:degree], self[:key], self[:scale], self[:octave])
        elsif self[:degrees]
          notes = []
          self[:degrees].each do |d|
            notes.push(get_note_from_dgr(self[:degree], self[:key], self[:scale], self[:octave]))
          end
          self[:notes] = notes
        end
      end

      def invert(start = 1, n=nil)
        self.transpose(-1, true).transpose(start)
      end

      def augment(additions)
        ziff = self.deep_clone
        if ziff[:note] and ziff[:degree] then
          if additions[:degree] then
            interval = additions[:degree]
          else
            interval = additions[ziff[:degree]]
          end
          interval = interval.() if (interval.is_a? Proc)
          ziff[:note] = get_interval_note ziff[:degree], interval, 0, ziff[:key], ziff[:scale]
        end
        ziff
      end

      def harmonize(degrees, compound = 0)
        ziff = self.deep_clone
          if ziff[:note] and ziff[:degree] then
            ziff[:notes] = []
            ziff[:notes].push ziff[:note]
            if compound>0 then
              scale_length = scale(ziff[:key],ziff[:scale]).length-1
              compound = scale_length * compound
            end
            if degrees.is_a? Hash then
              degree_intervals = degrees[ziff[:degree]]
              if degree_intervals then
                if degree_intervals.is_a? Array then
                  degree_intervals.each do |interval|
                    ziff[:notes].push get_interval_note ziff[:degree], interval, compound, ziff[:key], ziff[:scale]
                  end
                else
                  ziff[:notes].push get_interval_note ziff[:degree], degree_intervals, compound, ziff[:key], ziff[:scale]
                end
              end
            elsif degrees.is_a? Array
              degrees.each do |interval|
                ziff[:notes].push get_interval_note ziff[:degree], interval, compound, ziff[:key], ziff[:scale]
              end
            else
              ziff[:notes].push get_interval_note ziff[:degree], degrees, compound, ziff[:key], ziff[:scale]
            end
            ziff[:notes] = ziff[:notes].ring
            ziff[:notes] = chord_invert ziff[:notes], ziff[:chord_invert] if ziff[:chord_invert]
            ziff.delete(:note)
          end
        return ziff
      end

      def get_interval_note(degree, interval, compound, key, scale)
        add_to = 0
        if (interval.is_a? String) then
          if (interval.include? "#")
            interval = interval.sub "#",""
            add_to += 1
          elsif (interval.include? "b")
            interval = interval.sub "b",""
            add_to -= 1
          end
        end
        interval = interval.to_i
        interval = interval==0 ? interval+compound : interval>0 ? interval-1+compound : interval+1-compound
        return (get_note_from_dgr (degree+interval+compound), key, scale)+add_to
      end

      # TODO: Not used at this point
      def add_compound(ziff,interval)
        if interval>0 or interval<0 then
          if ziff[:note] then
            ziff[:notes] = []
            ziff[:notes].push ziff[:note]
            new_note = get_note_from_dgr ziff[:degree]+(interval-1), ziff[:key], ziff[:scale]
            scale_length = scale(ziff[:key],ziff[:scale]).length-1
            ziff[:notes].push new_note + scale_length
            ziff.delete(:note)
          end
        end
        return ziff
      end

      def detune(detune)
        ziff = self.deep_clone
        if ziff[:notes] then
          notes = ziff[:notes].to_a
          notes.each_with_index do |n,i|
            notes[i] = hz_to_midi(midi_to_hz(n)+detune)
          end
          ziff[:notes] = notes.ring
        elsif ziff[:note]
          ziff[:note] = hz_to_midi(midi_to_hz(ziff[:note])+detune)
        end
        ziff
      end

      def flex(ratio)
        ziff = self.deep_clone
        if ziff[:sleep] then
          ziff[:sleep] = ziff[:sleep] + ziff[:sleep]*ratio
          set_ADSR(ziff,@@default_opts.slice(:attack,:decay,:sustain,:release))
        end
        return ziff
      end

      # TODO: Chord degree silencing?
      def silence(degrees)
        ziff = self.deep_clone
        if ziff[:note] and ziff[:degree] then
          if ((degrees.is_a? Numeric) and degrees==ziff[:degree]) or ((degrees.is_a? Array) and (degrees.include? ziff[:degree]))  then
            ziff[:note] = :r
          end
        end
        return ziff
      end

  end
end
