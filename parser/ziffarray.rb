module Ziffers
  class ZiffArray < Array
    include Comparable

    def <=>(zarr)
      self.pcs <=> zarr.pcs
    end

    def +(x)
      ZiffArray.new(super)
    end

    def *(x)
      ZiffArray.new(super)
    end

    def &(x)
      ZiffArray.new(super)
    end

    def |(x)
      ZiffArray.new(super)
    end

    def transpose(start)
      ZiffArray.new(self.map {|n| n.transpose start })
    end

    def invert(start=1)
      ZiffArray.new(self.map {|n| n.invert start })
    end

    def retrograde(retrograde=true,chords=false)
      if retrograde == true
        return zreverse self, chords # Normal retrograde
      elsif retrograde.is_a?(Array) then # Retrograding subarray
        retrograde[1] = self.length if retrograde[1]>self.length or retrograde[1]<=retrograde[0]
        retrograde[0] = 0 if retrograde[0]<0
        rev_notes = []
        rev_notes += self[0,retrograde[0]] if retrograde[0]>0
        rev_notes += zreverse self[retrograde[0]..retrograde[1]], chords
        rev_notes += (retrograde[1]<self.length) ? self[retrograde[1]+1..self.length] : [self[retrograde[1]]] if retrograde[1]+1<self.length
        return rev_notes
      elsif retrograde.is_a?(Numeric) # Retrograding partial arrays splitted to equal parts
        zreverse self, chords if retrograde<2
        return self.each_slice(retrograde).map{|part| zreverse part, chords }.flatten
      end
    end

    # TODO: Need for custom reverse?
    # Reverses degrees but keeps the chords in place
    # Example: "i 1234 v 2341" -> "i 1432 v 4321"
    def zreverse(arr=nil, with_chords=false)
      arr = self if !arr
      i=0
      x=arr.length-1
      until x<=i do
        if !arr[i][:notes] or with_chords then
          if !arr[x][:notes] or with_chords then
            arr[i], arr[x] = arr[x], arr[i]
            i+=1
            x-=1
          else
            x-=1
          end
        else
          i+=1
        end
      end
      arr
    end

    def reverse
      ZiffArray.new(self.deep_clone.reverse_each.to_a)
    end

    def mirror(val=1)
      return self+self.reverse[1..] if val<2
      self.each_slice(val).map{|part| part+part.reverse[1..]}.flatten
    end

    def reflect
      part_b = self.reverse
      if part_b[0].is_a?(Array) then
        # TODO: What is this for?
        part_b = part_b.map { |arr| arr.reverse }
        part_b[0].shift
        part_b.delete_at(0) if part_b[0].empty?
        part_b[part_b.length-1].pop
        part_b.delete_at(part_b.length-1) if part_b[part_b.length-1].empty?
      else
        part_b.shift
        part_b.pop
      end
      return ZiffArray.new((self+part_b))
    end

    def swap(n,x=1)
      melody = self.dup
      n = n % melody.length if n>=melody.length
      n2 = (n+x)>=melody.length ? ((n+x) % melody.length) : n+x
      melody[n], melody[n2] = melody[n2], melody[n]
      melody
    end

    def stretch(val=1)
      (self.map{|z| [z]*val }).flatten
    end

    def deep_clone
      Marshal.load(Marshal.dump(self))
    end

    def powerset(val)
      self.combination(val).to_a.map {|x| ZiffArray.new(x)}
    end

    def repeated_powerset(val)
      self.repeated_combination(val).to_a.map {|x| ZiffArray.new(x)}
    end

    def set_operation(operator, values)
      notes = []
      self.each_with_index do |s,i|
        v = values[i]
        if v
          if s[:pc] and v[:pc]
            s[:pc] = s[:pc].to_i.method(operator).(v[:pc].to_i)
          elsif s[:pcs] and v[:pc]
            s[:pcs][0] = s[:pcs][0].to_i.method(operator).(v[:pc].to_i)
          elsif s[:pc] and v[:pcs]
            s[:pcs] = v[:pcs]
            s[:pcs][0] = s[:pcs][0].to_i.method(operator).(s[:pc].to_i)
            s.delete(:pc)
          elsif s[:pcs] and v[:pcs]
            v[:pcs].each_with_index do |d,di|
              if s[:pcs][di]
                s[:pcs][di] = s[:pcs][di].to_i.method(operator).(d.to_i)
              else
                s[:pcs].push(d)
              end
            end
          end
          notes.push(update_note s)
        end
      end
      notes
    end

    def keys(key)
      self.map{|x| x[key] or x[key]}
    end

    def pitch_classes
      self.map{|x| x[:pc] or x[:pcs]}
    end

    alias pcs pitch_classes

    def octaves
      self.map{|x| x[:octave] or x[:octave]}
    end

    def notes
      self.map{|x| x[:note] or x[:notes]}
    end

    def augment(opts)
      ZiffArray.new(self.map{|x| x.augment opts})
    end

    def harmonize(opts)
      ZiffArray.new(self.map{|x| x.harmonize opts})
    end

    def detune(opts)
      ZiffArray.new(self.map{|x| x.detune opts})
    end

    def silence(opts)
      ZiffArray.new(self.map{|x| x.silence opts})
    end

    def flex(opts)
      ZiffArray.new(self.map{|x| x.flex opts})
    end

    def multiply(opts)
      cl = self.deep_clone
      cl.each{|x| x.multiply opts; x.update_note}
      cl
    end

    def minus(opts)
      cl = self.deep_clone
      cl.each{|x| x.minus opts; x.update_note}
      cl
    end

    def plus(opts)
      cl = self.deep_clone
      cl.each{|x| x.plus opts; x.update_note}
      cl
    end

    def to_pc_set
      ZiffArray.new(self.uniq.sort_by { |hash| hash[:pc] })
    end

    #def sort
    # ZiffArray.new(self.sort_by { |hash| hash[:pc] })
    #end

    def content
      self
    end

    def cycles
      tempar = self.to_pc_set
      arar = []
      tempar.each {arar.push ZiffArray.new(tempar.unshift(tempar.pop))}
      arar
    end

    def normal_form
      most_left_compact(self.cycles)
    end

    def zero
      transpose(-1 * self[0][:pc])
    end

    def prime
      most_left_compact([self.normal_form.zero, self.invert.normal_form.zero])
    end

    # Adapted from: https://github.com/beausievers/Ruby-PCSet/blob/master/pcset.rb#L339
    def most_left_compact(pcset_array)
      if !pcset_array.all? {|pcs| pcs.length == pcset_array[0].length}
        raise ArgumentError, "PCSet.most_left_compact: All PCSets must be of same cardinality", caller
      end
      zeroed_pitch_arrays = pcset_array.map {|pcs| pcs.zero.pcs}
      binaries = zeroed_pitch_arrays.map {|array| array.inject(0) {|sum, n| sum + 2**n}}
      winners = []
      binaries.each_with_index do |num, i|
        if num == binaries.min then winners.push(pcset_array[i]) end
      end
      ZiffArray.new(winners.sort[0])
    end

  end
end
