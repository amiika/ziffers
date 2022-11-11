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

    # Endless list implementation
    def [](index,to=nil)
      return nil if !index
      if index.kind_of?(Range)
        to = index.end ? index.end : size-1
        index = index.begin ? index.begin : size-1
        if to<index
          from = index
          index = to
          to = from
          reverse = true
        end
        to = to-index
      end

      if to
        list = []
        while list.length<=to do
          list << super(index % size)
          index+=1
        end
        list = list.reverse if reverse
        ZiffArray.new(list)
      else
        super(index % size)
      end
    end

    def deep_clone
      ZiffHash[Marshal.load(Marshal.dump(self))]
    end

    def hash_measures
      self.group_by {|d| d.measure }
    end

    def measures
      self.hash_measures.values.map {|v| ZiffArray.new(v)}
    end

    def measure_durations
      self.measures.map {|l| l.sum {|h| h[:duration] ? h[:duration] : 0 }}
    end

    def measure_beats
      self.measures.map {|l| l.sum {|h| h[:beats] ? h[:beats] : 0 }}
    end

    def group_measures(i)
      self.measures.each_slice(i).collect do |s|
        s.map {|z| ZiffArray.new(z) }
      end
    end

    def subset(range)
      ZiffArray.new(self[range])
    end

    def vals(k)
      self.map{|v| v[k] || (v[:hpcs] && v[:hpcs].map{|p| p[k] }) || (v[:samples] && v[:samples].map{|p| p[k] })}
    end

    def tpcs
      self.map{|v| v.tpc}
    end

    def <=>(zarr)
      self.pcs <=> zarr.pcs
    end

    def -(x)
      ZiffArray.new(super)
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

    alias i inverse


    def samples
      self.map do |s|
        if s[:samples]
          s[:samples].map {|h| h[:sample] }
        else
          s[:sample]
        end
      end
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

    # Interpolate pitch classes
    # Does the same thing as: https://slonimsky.netlify.app/
    def interpolate(nodes=1, divisions=1)
      filtered_set = self.filter{|h| h.is_a?(Hash) and h[:pc] }
      new_pcs = nodes.times.collect { |i| [i * divisions] + filtered_set.map { |x| (i * divisions) + x.opc }}.flatten
      new_hpcs = new_pcs.map.with_index{|pc,i| ziff = filtered_set[i%filtered_set.length].dup; ziff[:pc] = pc ; ziff.update_note }
      a = ZiffArray.new(new_hpcs)
      a
    end

    def reverse
      ZiffArray.new(self.deep_clone.reverse_each.to_a)
    end

    def mirror(val=1)
      mirrored = self.deep_clone
      return ZiffArray.new(mirrored+mirrored.reverse[1..]) if val<2
      ZiffArray.new(mirrored.each_slice(val).map{|part| part+part.reverse[1..]}.flatten)
    end

    alias m mirror

    @@perm_cache = {}

    def permutation_index(index=nil,num=nil)

      notes, stuff = self.partition {|v| v.is_a? Hash }
      if !num
        num = notes.length
      elsif num>notes.length
        num = notes.length
      elsif num<1
        raise "Invalid permutation size!"
      end
      index = sonic_random(0, notes.length-1) if !index
      notes = ZiffArray.new(notes)
      perm_check = notes.to_z+">>"+num.to_s+":"+index.to_s
      if @@perm_cache[perm_check]
        perm = @@perm_cache[perm_check]
      else
        perm = notes.permutation(num).to_a
        @@perm_cache[perm_check] = perm
      end
      res = perm[index%perm.length]
      ZiffArray.new(stuff.compact+res)
    end

    alias p permutation_index

    def tonnetz(val)
      ZiffArray.new(self.map {|h| h[:hpcs] ? (apply_moves val, h) : h}.flatten)
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

    alias r reflect

    def swap(n,x=1)
      melody = self.deep_clone
      n = n % melody.length if n>=melody.length
      n2 = (n+x)>=melody.length ? ((n+x) % melody.length) : n+x
      melody[n], melody[n2] = melody[n2], melody[n]
      melody
    end

    def stretch(val=2)
      ZiffArray.new((self.deep_clone.map{|z| [z]*val }).flatten)
    end

    alias s stretch

    def deal(val=2)
      self.group_by.with_index {|z,i| i % val }.values.map {|arr| ZiffArray.new(arr.reverse) }
    end

    alias d deal

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
      self.map{|x| x.pc }
    end

    def opcs
      self.map{|x| x.opc }
    end

    def cpcs
      self.map{|x| x.cpc }
    end

    # Natural degrees
    def degrees
      self.map{|x| x.dgr or (x[:hpcs] and x[:hpcs].map{|p| p.dgr })}
    end

    # Chromatic pitch classes
    def cpcs
      self.map{|x| x.cpc or (x[:hpcs] and x[:hpcs].map{|p| p.cpc })}
    end

    # Original degrees (Saved before parsing)
    def orig_pcs
      self.map{|x| x[:pc_orig] or (x[:hpcs] and x[:hpcs].map{|p| p[:pc_orig]}) }
    end

    alias pcs pitch_classes

    def octaves
      self.map{|x| x[:octave] or (x[:hpcs] and x[:hpcs].map{|p| p[:octave]})}
    end

    def pitches
      self.map{|x| x[:pitch] or (x[:samples] and x[:samples].map{|p| p[:pitch]})}
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

    def fuse(inject_melody)
      ZiffArray.new(self.inject(inject_melody){|a,j| a.flat_map{|n| [n,j.augment(n)]}})
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

    def to_z
      self.map {|h| h.is_a?(ZiffHash) ? h.to_z : h.to_s }.join(" ")
    end

    def content
      self
    end

    def intervals
      pcs = self.pcs.filter {|v| v.is_a? Integer }
      pcs.map.with_index {|v,i|
        pc_int(v, pcs[(i+1)%pcs.length])
      }
    end

    def chord_intervals
      self.map {|v| v.chord_intervals }
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

    # Vertical arpeggio generator for generative syntax
    def gen_arp(opts)
      v = self.map.with_index do |ziff,i|
        if ziff.is_a?(String)
          ziff
        elsif ziff[:hpcs]
          opts.map do |cn|
            if cn.is_a?(String)
              cn
            elsif cn[:hpcs]
              arp_chord = cn[:hpcs].map{|d| h = ZiffHash[ziff[:hpcs][d[:pc]%ziff[:hpcs].length].dup] ; h = h.merge(d.slice(:prefix,:octave,:add,:amp,:duration)) ; h.update_note ; h }
              ziff_dup = ziff.dup
              ziff_dup[:hpcs] = arp_chord
              ZiffHash[ziff_dup]
            else
              ziff_dup = ziff[:hpcs][cn[:pc]%ziff[:hpcs].length].dup
              ziff_dup = ziff_dup.merge(cn.slice(:prefix,:octave,:add,:amp,:duration))
              h = ZiffHash[ziff_dup]
              h.update_note
              h
            end
          end
        else
          # ziff[:prefix] = opts[i%opts.length] if opts[i%opts.length].is_a?(String)
          ziff
        end
      end
      ZiffArray.new(v.flatten)
    end

    # Horizontal arpeggio generator for generative syntax
    def gen_select(opts)
        select = self.filter {|v| v.is_a? Hash }
        v = opts.map.with_index do |cn, i|
            if cn.is_a?(String)
              cn
            elsif cn[:hpcs]
              new_chord = cn[:hpcs].map{|d| h = select[d[:pc]%select.length] ; h = h.merge(d.slice(:prefix,:octave,:add,:amp,:duration)) ; h }
              ZiffHash[{hpcs: new_chord}]
            else
              ziff_dup = select[cn[:pc]%select.length].dup
              ziff_dup = ziff_dup.merge(cn.slice(:prefix,:octave,:add,:amp,:duration))
              ZiffHash[ziff_dup]
            end
          end
      ZiffArray.new(v.flatten)
    end

    def zip_ring(opts)
      max_length = [self.length,opts.length].max
      v = max_length.times.collect do |i|
        [self[i%self.length]].push(opts[i%opts.length])
      end
      ZiffArray.new(v.flatten)
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

    alias norm normal_form

    def zero
      transpose(-1 * self[0][:pc])
    end

    def prime
      ZiffArray.new(most_left_compact([self.normal_form.zero, self.inverse.normal_form.zero]))
    end

    def durations
      self.map{|x,i| x.duration }
    end

    def beats
      self.map{|x,i| x.beats }
    end

    def duration
      self.durations.inject(0){|sum,x| sum+x }
    end

    def duration_in_beats
      self.beats.inject(0){|sum,x| sum+x }
    end

    def rotate(v=1)
      ZiffArray.new(super)
    end

    alias rot rotate

    def merge_lengths(arr, loop_n=0)
      ZiffArray.new(self.map.with_index{|x,i| x.clone_and_update_duration(arr[(i+loop_n)%arr.length]) })
    end

    def modify_rhythm(val, loop_n=0, rhythm_map=nil)
      new_arr = self.deep_clone
      val = val.() if val.is_a? Proc
      if val.is_a?(Array) and (!val.union([true,false]).difference([true,false]).any? or !val.union([1,0]).difference([1,0]).any?)
        pattern = parse_binary(val, 1.0, rhythm_map) # If boolean or bool as int array
      elsif val.is_a?(Array)
        pattern = val.map {|v| v.is_a?(Float) ? v : int_to_length(v)}
      elsif val.is_a?(SonicPi::Core::RingVector)
        if !val.to_a.union([true,false]).difference([true,false]).any? or !val.to_a.union([1,0]).difference([1,0]).any?
          pattern = parse_binary(val, 1.0, rhythm_map) # If boolean ring
        else
          pattern = val.map {|v| v.is_a?(Float) ? v : int_to_length(v)}
        end
      elsif val.is_a?(Integer)
        pattern = ints_to_lengths(val.to_s.split("").map{|v| v.to_i}, rhythm_map)
      elsif val.is_a?(Hash)
        rhythm_map = val[:durs] if val[:durs]
        numbers = val.slice(0,1,2,3,4,5,6,7,8,9,10,11)
        if numbers and numbers.size>0
          pattern = map_pcs_to_durations(numbers)
        elsif val[:binary]
          val[:binary] = val[:binary].() if val[:binary].is_a? Proc
          pattern = parse_binary(val[:binary], (val[:ratio] ? val[:ratio] : 1.0), rhythm_map)
        elsif val[:minor] and val[:major]
          pattern = schillinger(val, rhythm_map)
        elsif val[:pattern]
          pattern = val[:pattern]
        end
        pattern = transform_rhythm val, pattern
      elsif val.is_a?(String)
        pattern = val.split(val.include?(" ") ? /[\s\t\r\n]/ : "").map  do |ch|
          if (@@default_durs.keys.include? ch.to_sym)
            @@default_durs[ch.to_sym] # Map chars to default lengths
          elsif ch.match(/^(\d)+$/)
            int_to_length(ch.to_i) # Map ints to default lengths
          else
            get_default(:duration)
          end
        end
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

    def resolve_strings
      last_duration = get_default(:duration)
      last_octave = 0
      new_list = self.flatten.compact.map do |h|
        if h.is_a?(String)
          if h.include?("_") || h.include?("^")
            last_octave = h.split("").map {|v| (v=='^' ? 1 : -1)}.inject(0,:+)
          else
            last_duration = h.split("").map {|v| @@default_durs[v.to_sym] }.compact.inject(0,:+)
          end
          nil
        elsif h.is_a?(ZiffHash)
          h[:duration] = last_duration if !h[:duration]
          h[:octave] = last_octave if !h[:octave]
          h
        else
          nil
        end
      end
      ZiffArray.new(new_list.compact)
    end

    def transform_rhythm(opts,pattern=nil)
      if !pattern
        pattern = self.durations
      else
        pattern = ZiffArray.new(pattern) if pattern.is_a?(Array)
      end
      opts.each do |key,val|
        case key
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

    def filter_chords
      self.filter {|h| h[:hpcs] }
    end

    def notes_from_pcs
      self.map {|h| h.notes_from_pcs }
    end

    def voice_leading
      self.map.with_index do |h,i|
        if h[:hpcs]
          if i>0
            new_notes = voice_lead(self[i-1].notes_from_pcs,h.notes_from_pcs)
            new_notes.map.with_index {|v,i| h[:hpcs][i][:note] = v}
            h.update_pcs
            h
          else
            h
          end
        else
          h
        end
      end
    end

    alias v voice_leading
    alias lead voice_leading

  end
end
