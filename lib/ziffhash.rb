module Ziffers
  class ZiffHash < Hash

      def eql?(other_hash)
        @@set_keys.filter {|key| self[key] == other_hash[key]} == @@set_keys
      end

      # TODO: Add other keys to hash?
      def hash
          self[:pc].hash
      end

      def pc
        self[:pc]
      end

      def dgr
        self[:pc]+1
      end

      def note
        self[:note]
      end

      def deep_clone
        ZiffHash[Marshal.load(Marshal.dump(self))]
      end

      def pitch_class
        self[:pc]
      end

      def minus val
        self[:pc]-=val
      end

      def plus val
        self[:pc]+=val
      end

      def multiply val
        self[:pc]*=val
      end

      def note_name
        note_info(self[:note]).pitch_class
      end

      def midi_name
        note_info(self[:note]).midi_string
      end

      def transpose(i, inv=false)
        ziff = self.deep_clone
        if ziff[:note]!=:r
          n = scale(ziff[:key], ziff[:scale]).length-1
          if ziff[:pcs]
            ziff[:pcs].each_with_index do |originalDegree, index|
              val = inv ? i-originalDegree : originalDegree+i
              ziff[:octave] += val/n if val>=n or val<0
              val = val % n
              ziff[:pcs][index] = val
              ziff.update_note
            end
          elsif ziff[:pc]
            originalDegree = ziff[:pc]
            val = inv ? i-originalDegree : originalDegree+i
            ziff[:octave] += val/n if val>=n or val<0
            val = val % n
            ziff[:pc] = val
            ziff.update_note
          end
        end
        ziff
      end

      # TODO: Add ignore_octave parameter?
      def update_note
        if self[:pc]
          self.merge!(get_ziff(self[:pc], self[:key], self[:scale], self[:octave]))
        elsif self[:pcs]
          notes = []
          self[:pcs].each do |d|
            notes.push(get_note_from_dgr(d, self[:key], self[:scale], self[:octave]))
          end
          self[:notes] = notes
        end
      end

      # 0 inverts around 0, 1 inverts between 0 and 1, -1 inverts between 0 and -1.
      # To invert around n = n+n
      def inverse(start=0)
        start = 0 if [true, false].include?(start) and start
        self.transpose(-1, true).transpose(start+1)
      end

      def augment(additions)
        ziff = self.deep_clone
        if ziff[:note] and ziff[:pc] then
          if additions[:pc] then
            interval = additions[:pc]
          else
            interval = additions[ziff[:pc]]
          end
          interval = interval.() if (interval.is_a? Proc)
          ziff[:note] = get_interval_note ziff[:pc], interval, 0, ziff[:key], ziff[:scale]
        end
        ziff
      end

      def harmonize(degrees, compound = 0)
        ziff = self.deep_clone
          if ziff[:note] and ziff[:pc] then
            ziff[:notes] = []
            ziff[:notes].push ziff[:note]
            if compound>0 then
              scale_length = scale(ziff[:key],ziff[:scale]).length-1
              compound = scale_length * compound
            end
            if degrees.is_a? Hash then
              degree_intervals = degrees[ziff[:pc]]
              if degree_intervals then
                if degree_intervals.is_a? Array then
                  degree_intervals.each do |interval|
                    ziff[:notes].push get_interval_note ziff[:pc], interval, compound, ziff[:key], ziff[:scale]
                  end
                else
                  ziff[:notes].push get_interval_note ziff[:pc], degree_intervals, compound, ziff[:key], ziff[:scale]
                end
              end
            elsif degrees.is_a? Array
              degrees.each do |interval|
                ziff[:notes].push get_interval_note ziff[:pc], interval, compound, ziff[:key], ziff[:scale]
              end
            else
              ziff[:notes].push get_interval_note ziff[:pc], degrees, compound, ziff[:key], ziff[:scale]
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
            new_note = get_note_from_dgr ziff[:pc]+(interval-1), ziff[:key], ziff[:scale]
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

      def duration
        self[:sleep]
      end

      def change_duration(val)
        ziff = self.deep_clone
        ziff[:sleep] = val if val
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
        if ziff[:note] and ziff[:pc] then
          if ((degrees.is_a? Numeric) and degrees==ziff[:pc]) or ((degrees.is_a? Array) and (degrees.include? ziff[:pc]))  then
            ziff[:note] = :r
          end
        end
        return ziff
      end

  end
end
