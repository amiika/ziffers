module Ziffers
  class ZiffHash < Hash

      def eql?(other_hash)
        @@set_keys.filter {|key| self[key] == other_hash[key]} == @@set_keys
      end

      # TODO: Add other keys to hash?
      def hash
          self[:pc].hash
      end

      # Pitch class number
      def pc
        return self.pcs if self[:hpcs]
        self[:pc]
      end

      def evaluate_string_octave
        return 0 if !self[:octave]
        return self[:octave] if self[:octave].is_a?(Integer)
        return self[:octave].split("").map {|v| v=="^" ? 1 : -1 }.inject(0){|a,b| a+b } if self[:octave].is_a?(String)
        return 0
      end

      # Pitch class number with octave
      def opc
        return self.opcs if self[:hpcs]
        self[:pc]+(self[:octave] ? self[:octave]*self[:scale_length] : 0)
      end

      def pcs
        self[:hpcs].map {|h| h[:pc] }
      end

      def dgrs
        self[:hpcs].map {|h| h.dgr }
      end

      def opcs
        self[:hpcs].map {|h| h[:pc]+(h[:octave] ? h[:octave]*h[:scale_length] : 0) }
      end

      def notes
        self[:notes] || [self[:note]]
      end

      def notes_from_pcs
        if self[:hpcs]
          self[:hpcs].map {|h| get_note_from_dgr h[:pc], h[:key], h[:scale], (h[:octave] || 0), (h[:add] || 0) }
        else
          get_note_from_dgr self[:pc], self[:key], self[:scale], (h[:octave] || 0), (h[:add] || 0)
        end
      end

      def multiply_chord_octaves!(oct)
        if self[:hpcs]
          dup = 1.upto(oct-1).collect do |i|
            self[:hpcs].map  do |h|
               h = ZiffHash[h.dup]
               if !h[:octave]
                 m_oct = 0
               else
                 m_oct = h[:octave].evaluate_string_octave
               end
               h[:octave] = (m_oct || 0)+i
               h
            end
          end
          self[:hpcs] = self[:hpcs]+dup.flatten
        end
      end

      # Chord inversion
      def inv_chord!(val)
        arr = val<0 ? self[:hpcs].reverse : self[:hpcs]
        (val.abs).times do |i|
          chord_pc = arr[i%self[:hpcs].length]
          chord_pc[:octave] = chord_pc.evaluate_string_octave # Get exact octave
          chord_pc[:octave] += (val<0 ? -1 : 1)
        end
        # NOTE: Rotate orders by note value ... but in some cases root order is assumed.
        self[:hpcs] = self[:hpcs].rotate(val)
        self.update_note
      end

      # Degree with octave
      def dgr
        if self[:pc]
          self.opc+1
        elsif self[:hpcs]
          self[:hpcs].map {|h| h.opc+1 }
        else
          nil
        end
      end

      # Chromatic pitch class
      def cpc
        return self.pcs if self[:scale] == :chromatic
        if self[:hpcs]
          self[:hpcs].map {|h| get_note_from_dgr(h.pc,0,self[:scale]) + (h[:add]?h[:add]:0)}
        else
          get_note_from_dgr(self.pc,0,self[:scale])
        end
      end

      # Chord intervals
      def chord_intervals
        if self.is_chord?
          self.cpc.uniq.sort.each_cons(2).to_a.map {|v| v[1]-v[0] }
        else
          nil
        end
      end

      def get_chord_degrees
        intervals_to_chord_degrees = {
          # Major intervals
          [4,3]=> [1,3,5],
          [7,-3]=> [1,3,5],
          [8,-5]=> [3,1,5],
          [5,4]=> [5,1,3],
          [3,5]=> [3,5,1],
          [9,-4]=> [5,3,1],
          # Minor intervals
          [3,4]=> [1,3,5],
          [7,-4]=> [1,3,5],
          [9,-5]=> [3,1,5],
          [5,3]=> [5,1,3],
          [4,5]=> [3,5,1],
          [8,-3]=> [5,3,1]
          }
          intervals_to_chord_degrees[self.chord_intervals]
      end

      def is_major_chord?
        if self.is_chord?
          [[4,3],[3,5],[5,4]].include?(self.chord_intervals)
        else
          nil
        end
      end

      def tpc
        midi_to_tpc(self[:note],self[:key])
      end

      def note
        self[:note]
      end

      def measure
        self[:measure]
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

      # TODO: Do this based on tcp value instead
      def note_name
        note_info(self[:note]).pitch_class
      end

      def to_z
        if self[:duration]
          duration_value = @@default_durs.key(self[:duration])
          duration_value = "<"+self[:duration].to_s+">" if !duration_value
        end
        if self[:octave]
          if self[:octave].is_a?(Integer)
            octave_value = "<"+self[:octave].to_s+">" #(self[:octave]>0 ? "^"*self[:octave] : "_"*self[:octave].abs)
          else
            octave_value = self[:octave].to_s
          end
        end
        if self[:pc]
          pc = ((self[:pc].to_i>9 or self[:pc].to_i<-9 or self[:pc].is_a?(Float))  ? "{#{self[:pc].to_s}}" : self[:pc].to_s)
        end
        if self[:add]
          add = self[:add]>0 ? "#"*self[:add] : "b"*self[:add].abs  if self[:add].is_a?(Integer) and self[:add]!=0
        end
        zs =  (self[:prefix] || "") +
              (add || "") +
              (self[:staccato] || "") +
              (self[:dynamics] || "") +
              (octave_value || "") +
              ((duration_value and !self[:hpcs] and !self[:samples]) ? duration_value.to_s : "") +
              ((self[:note] and self[:note]==:r) ? "r" : "") +
              (self[:char] || "") +
              (pc || "") +
              (self[:hpcs] ? self[:hpcs].map {|h| h.to_z }.join("") : "") +
              (self[:samples] ? self[:samples].map {|h| h.to_z }.join("") : "")
        zs
      end

      def midi_name
        note_info(self[:note]).midi_string
      end

      def is_chord?
        self[:hpcs]
      end

      # OIS - ordered pitch-class intervallic structure
      def ois(r=nil)
        if self[:hpcs]
          r = self[:hpcs][0][:pc] if !r
          return self.pcs.map {|v| pc_int(r, v) }
        else
          return nil
        end
      end

      def to_pc_set
        return self if !self[:pcs]
        temp = self.deep_clone
        temp[:hpcs] = temp[:hpcs].select{|v| v[:pc] }.uniq.sort_by { |hash| hash[:pc] }
        temp.update_note
        temp
      end

      def cycles
        return self if !self[:pcs]
        tempar = self.to_pc_set
        arar = []
        tempar[:hpcs].length.times do
            tempar[:hpcs] = tempar[:hpcs].unshift(tempar[:hpcs].pop)
            arar.push tempar.deep_clone
          end
        arar
      end

      def normal_form
        return self if !self[:pcs]
        most_left_compact(self.cycles)
      end

      def zero
        transpose(-1 * self[:hpcs][0][:pc])
      end

      def prime
        return self if !self[:pcs]
        most_left_compact([self.normal_form.zero, self.inverse.normal_form.zero])
      end

      def transpose(i, inv=false)
        ziff = self.deep_clone
        if ziff[:note]!=:r
          n = scale(ziff[:key], ziff[:scale]).length-1
          if ziff[:hpcs]
            ziff[:hpcs].each_with_index do |h, index|
              val = inv ? i-h[:pc] : h[:pc]+i
              ziff[:octave] = -ziff[:octave] if inv and ziff[:octave]
              h[:octave] += val/n if val>=n or val<0
              val = val % n
              h[:pc] = val
              ziff.update_note
            end
          elsif ziff[:pc]
            originalDegree = ziff[:pc]
            val = inv ? i-originalDegree : originalDegree+i
            ziff[:octave] = -ziff[:octave] if inv and ziff[:octave]
            ziff[:octave] += val/n if val>=n or val<0
            val = val % n
            ziff[:pc] = val
            ziff.update_note
          end
        end
        ziff
      end

      # Update notes based on pitch class values
      def update_note(update_octave=true) # Update_octave=false used in generative parsing
        if self[:pc]
          self.merge!(get_ziff(self[:pc], self[:key], self[:scale],(update_octave ? (self[:octave] || 0) : false),(self[:add] || 0)))
        elsif self[:hpcs]
          notes = []
          self[:hpcs].each do |d|
            pc = d[:pc]
            notes.push(get_note_from_dgr(pc, d[:key], d[:scale], (d[:octave] || 0)) + (self[:add] || 0))
          end
          self[:pcs] = self[:hpcs].map {|h| h[:pc] }
          self[:notes] = notes
        end
      end

      # Update pcs based on note values
      def update_pcs
        if self[:pc]
          new_ziff = midi_to_pc(self[:note],self[:key],self[:scale])
          self[:pc] = new_ziff[:pc]
          self[:add] = new_ziff[:add]
        elsif self[:hpcs]
          new_pcs = []
          self[:hpcs].each do |d|
            new_pcs << midi_to_pc(d[:note],d[:key],d[:scale])
          end
          self[:hpcs] = new_pcs
          self[:pcs] = new_pcs.map {|h| h[:pc] }
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
          ziff[:pc] = ziff[:pc]+interval
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
        self[:duration]
      end

      def beats
        self[:beats]
      end

      def clone_and_update_duration(val)
        ziff = self.deep_clone
        ziff[:duration] = val if val
        ziff[:beats] = ziff[:duration]*4
        ziff.update_ADSR!
        ziff
      end

      def update_ADSR!
          [:attack,:decay,:sustain,:release].each do |key|
            if self[key] and self[key].is_a?(Numeric)
              self[key] = (self[:duration]*self[key])*4 if get_default(:relative_adsr)
              self[key] = (self[key]/self[:stacc])+((self[key]/2)/self[:stacc]) if self[:stacc]
          end
        end
      end

      def intervals(val, defaults)
        ziff = self.deep_clone
        ziff[:pc_intervals] = val+ziff[:pc_orig]
        ziff[:pc] = ziff[:pc_intervals]
        ziff[:octave] = defaults[:octave] || 0
        ziff.update_note
        defaults[:intervals] = ziff[:pc_intervals]
        return ziff
      end

      def flex(ratio)
        ziff = self.deep_clone
        if ziff[:duration] then
          ziff[:duration] = ziff[:duration] + ziff[:duration]*ratio
          ziff[:beats] = ziff[:duration]*4
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
