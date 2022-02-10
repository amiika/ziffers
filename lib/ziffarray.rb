require_relative "./generators.rb"
require_relative "./defaults.rb"

'''
# For testing and debugging
load "~/ziffers/lib/generators.rb"
load "~/ziffers/lib/defaults.rb"
'''

module Ziffers
  class ZiffArray < Array
    include Comparable
    include Ziffers::Generators
    include Ziffers::Defaults

    def deep_clone
      ZiffHash[Marshal.load(Marshal.dump(self))]
    end

    def hash_measures
      self.group_by {|d| d.measure }
    end

    def measures
      self.hash_measures.values.map {|v| ZiffArray.new(v)}
    end

    def group_measures(i)
      self.measures.each_slice(i).collect do |s|
        s.map {|z| ZiffArray.new(z) }
      end
    end

    def subset(range)
      ZiffArray.new(self[range])
    end

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
      return self if start==0
      ZiffArray.new(self.map {|n| n.transpose start })
    end

    def inverse(start=0)
      start = 0 if [true, false].include?(start) and start
      ZiffArray.new(self.map {|n| n.inverse start })
    end

    def duration
      self.durations.inject(0){|sum,x| sum+x }
    end

    def samples
      self.map {|s| s[:sample] }
    end

    def retrograde(retrograde=true, chords=false)
      copy = self.deep_clone
      if retrograde == true
        copy = zreverse copy, chords # Normal retrograde
      elsif retrograde.is_a?(Range) then # Retrograding subarray
        end_retro = retrograde.last
        start_retro = retrograde.first
        rev_notes = []
        rev_notes += copy[0,start_retro] if start_retro>0
        rev_notes += zreverse copy[start_retro..end_retro], chords
        rev_notes += (end_retro<copy.length) ? copy[end_retro+1..copy.length] : [copy[end_retro]] if end_retro+1<copy.length
        copy = rev_notes
      elsif retrograde.is_a?(Numeric) # Retrograding partial arrays splitted to equal parts
        copy = retrograde<2 ? zreverse(copy, chords) : copy.each_slice(retrograde).map{|part| zreverse part, chords }.flatten
      end
      return ZiffArray.new(copy)
    end

    # Reverses degrees but keeps the chords in place
    # Example: "i 1234 v 2341" -> "i 1432 v 4321"
    def zreverse(arr, with_chords=false)
      if arr[0] and arr[0].is_a?(Hash)
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
      else
        arr = arr.reverse
      end
      arr
    end

    def reverse
      ZiffArray.new(self.deep_clone.reverse_each.to_a)
    end

    def mirror(val=1)
      mirrored = self.deep_clone
      return ZiffArray.new(mirrored+mirrored.reverse[1..]) if val<2
      ZiffArray.new(mirrored.each_slice(val).map{|part| part+part.reverse[1..]}.flatten)
    end

    def reflect
      reflected = self.deep_clone
      part_b = reflected.reverse
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
      return ZiffArray.new((reflected+part_b))
    end

    def swap(n,x=1)
      melody = self.deep_clone
      n = n % melody.length if n>=melody.length
      n2 = (n+x)>=melody.length ? ((n+x) % melody.length) : n+x
      melody[n], melody[n2] = melody[n2], melody[n]
      melody
    end

    def stretch(val=1)
      (self.deep_clone.map{|z| [z]*val }).flatten
    end

    def deal(val=2)
      self.group_by.with_index {|z,i| i % val }.values.map {|arr| ZiffArray.new(arr) }
    end

    def deep_clone
      Marshal.load(Marshal.dump(self))
    end

    def superset(val)
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

    def pitch_classes
      self.map{|x| x[:pc] or (x[:hpcs] and x[:hpcs].map{|p| p[:pc]})}
    end

    def orig_pcs
      self.map{|x| x[:pc_orig] or (x[:hpcs] and x[:hpcs].map{|p| p[:pc_orig]}) }
    end

    alias pcs pitch_classes

    def octaves
      self.map{|x| x[:octave] or x[:octave]}
    end

    def notes
      self.map{|x| x[:note] or x[:notes]}
    end

    def note_names
      self.map{|x| x.note_name }
    end

    def midi_names
      self.map{|x| x.midi_name }
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

    def multiply(val)
      cl = self.deep_clone
      cl.each{|x| x.multiply val; x.update_note}
      cl
    end

    def minus(val)
      cl = self.deep_clone
      cl.each{|x| x.minus val; x.update_note}
      cl
    end

    def plus(val)
      cl = self.deep_clone
      cl.each{|x| x.plus val; x.update_note}
      cl
    end

    def production(set,p=:pc)
      cartesian_product(set,"*",p)
    end

    def summation(set,p=:pc)
      cartesian_product(set,"+",p)
    end

    def substraction(set,p=:pc)
      cartesian_product(set,"-",p)
    end

    def cartesian_product(set, operator="+", p=:pc)
      cl = self.deep_clone
      cl = set.map do |z|
          cl.map  do |c|
            copy = c.deep_clone
            if z and c and z[p] and c[p]
              copy[p] = z[p].method(operator).(c[p])
              copy.update_note
            end
            copy
          end
        end
      ZiffArray.new(cl.flatten)
    end

    def to_pc_set
      ZiffArray.new(self.select{|v| v[:pc] }.uniq.sort_by { |hash| hash[:pc] })
    end

    #def sort
    # ZiffArray.new(self.sort_by { |hash| hash[:pc] })
    #end

    def content
      self
    end

    def intervals
      pcs = self.pcs.filter {|v| v.is_a? Integer }
      pcs.map.with_index {|v,i|
        pc_int(v, pcs[(i+1)%pcs.length])
      }
    end

    # OIS - ordered pitch-class intervallic structure
    def ois(r=nil)
      #arr = self.pitch_classes #.select {|v| v.is_a?(Integer)}.compact
      if self.length>0
        pc_list = self.select {|v| v[:pc] }.compact
        if !r
          r = pc_list[0][:pc] if pc_list[0]
        end
        if pc_list.length==0
          return self.map {|v| v.ois }
        else
          return self.map {|v| (v[:pc] and v[:pc].is_a?(Integer)) ? pc_int(r, v[:pc]) : v.ois }
        end
      else
        return nil
      end
    end

    def cycles
      tempar = self.to_pc_set
      arar = []
      tempar.each {arar.push ZiffArray.new(tempar.unshift(tempar.pop))}
      arar
    end

    def normal_form
      ZiffArray.new(most_left_compact(self.cycles))
    end

    def zero
      transpose(-1 * self[0][:pc])
    end

    def prime
      ZiffArray.new(most_left_compact([self.normal_form.zero, self.inverse.normal_form.zero]))
    end

    def durations
        ZiffArray.new(self.map{|x,i| x.duration })
    end

    def merge_lengths(arr, loop_n=0)
      ZiffArray.new(self.map.with_index{|x,i| x.change_duration arr[(i+loop_n)%arr.length]})
    end

    def schillinger(opts)
      if opts[:third] and opts[:major] and opts[:minor]
        if opts[:complementary]
         resultant = complementary(opts[:major], opts[:minor], opts[:third])
        else
          resultant = generator(opts[:major], opts[:minor], opts[:third])
        end
      elsif opts[:major] and opts[:minor]
        if opts[:secondary]
          resultant = secondary(opts[:major], opts[:minor])
        else
          resultant = generator(opts[:major],opts[:minor])
        end
      end
      ints_to_lengths resultant
    end

    def modify_rhythm(val, loop_n=0)
      new_arr = self.deep_clone
      if val.is_a?(Array)
        pattern = val.map {|v| v.is_a?(Float) ? v : int_to_length(v)}
      elsif val.is_a?(SonicPi::Core::RingVector)
        pattern = ints_to_lengths(bools_to_seq(val))
      elsif val.is_a?(Integer)
        pattern = ints_to_lengths(val.to_s.split("").map{|v| v.to_i})
      elsif val.is_a?(Hash)
        # TODO: Create more elegant functions for hex etc.
        numbers = val.slice(0,1,2,3,4,5,6,7,8,9,10,11)
        pattern = ints_to_lengths(bools_to_seq(val[:hex].to_s(2).split("").map{|b| b=="1" ? true : false }.flatten)) if val[:hex]
        pattern = map_pcs_to_durations(numbers) if numbers and numbers.size>0
        pattern = schillinger(val) if val[:minor] and val[:major]
        pattern = val[:pattern] if val[:pattern]
        pattern = transform_rhythm val, pattern
      elsif val.is_a?(String)
        #.bytes.map {|v| v.to_s(2).split("").map{|b| b=="1" ? true : false } }.flatten
        pattern = val.delete(" \t\r\n").split("").reduce([]) { |acc,c| (@@default_durs.keys.include? c.to_sym) ? acc << @@default_durs[c.to_sym] : acc }
      end
      new_arr = new_arr.merge_lengths(pattern, loop_n)
      new_arr
    end

    def map_pcs_to_durations(numbers)
      new_durations = self.pcs.map {|v|
        n = numbers[v]
        n = @@default_durs[n.to_sym] if n.is_a?(String) and @@default_durs.keys.include?(n.to_sym)
        n
      }
      new_durations
    end

    def transform_rhythm(opts,pattern=nil)
      pattern = self.durations if !pattern
      opts.each do |key,val|
        case key
        when :retrograde then
           pattern = pattern.retrograde val
        when :swap then
          pattern = pattern.swap *val
        when :rotate then
          pattern = pattern.rotate(val)
        when :mirror then
          pattern = pattern.mirror
        when :reverse then
          pattern = pattern.reverse
        when :reflect then
          pattern = pattern.reflect
        end
      end
      pattern
    end

  end
end
