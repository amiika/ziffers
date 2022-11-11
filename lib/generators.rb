require_relative "./defaults.rb"

'''
# For testing and debugging
load "~/ziffers/lib/defaults.rb"
'''

module Ziffers
  module Generators
    include Ziffers::Defaults

  def ints_to_lengths(val,map=nil)
    val.map {|n| int_to_length(n,map) }
  end

  # Creates tone matrix from the given row. Given row should be in a prime form and contain only unique integers
  def prime_rows(row)
    size = row.length
    size.times.collect {|i|
      interval = row[i]<row[0] ? (row[i]-row[0]) : (row[i]-row[0]-size)
      size.times.collect {|j|
        (row[j]-interval) % size
      }
    }
  end

  def prime_retrogrades(prime_rows)
    prime_rows.map{|r| r.reverse}
  end

  def prime_inversions(prime_rows)
    prime_rows.transpose
  end

  def prime_retrograde_inversions(prime_rows)
    prime_rows.reverse.transpose
  end


  # Schillinger rhythm generator

  def schillinger(opts,map=nil)
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
    ints_to_lengths resultant, map
  end

  # Schillinger resultants
  def resultants(major,minor,secondary=false)
    result = secondary ? secondary(major, minor) : generator(major,minor)
    ints_to_lengths(result)
  end

  def trinomial(major,minor,third,complementary=false)
    result = complementary ? complementary(major, minor, third) : generator(major, minor, third)
    ints_to_lengths(result)
  end

  def generator(major, minor, third=nil)
    cp = major * minor
    cp = cp * third if third
    counter = 0
    resultant = 1.upto(cp).collect do |i|
      counter+=1
      if ((i % major==0) || (i % minor==0) || (third && (i % third==0)))
        duration = counter
        counter = 0
        duration
      end
    end
    resultant.compact
  end

  def complementary(major,minor,third)
    cp = major*minor*third
    counter = 0
    resultant = 1.upto(cp).collect do |i|
      counter+=1
      if (i%(major*minor)===0 || i%(major*third)===0 || i%(minor*third)===0)
        duration = counter
        counter = 0
        duration
      end
    end
    resultant.compact
  end

  def secondary(major, minor)
    cp = major * major
    counter = 0
    s_i = 0
    phase = 0
    resultant = 1.upto(cp).collect do |i|
      counter+=1
      s_i+=1 if phase>=2 # Start secondary after second phase
      if ((i % major==0) || (i<(major*minor) && i % minor==0) || (phase>=2 && (s_i%minor==0)))
        phase+=1
        duration = counter
        counter = 0
        duration
      end
    end
    resultant.compact
  end

  # Morrills Euclidean algorithm
  #https://arxiv.org/pdf/2206.12421.pdf
  def euclidean_morrill(pulses, length)
    return Array.new(length,1) if pulses>=length
    res_list = -1.upto(length-1).collect {|t| pulses * t % length }
    length.times.collect {|index| starts_descent(res_list, index) }
  end

  def starts_descent(list, index)
    length = list.length
    next_index = (index + 1) % length
    list[index] > list[next_index] ? 1 : 0
  end

 # Turns binary/boolean sequence to intervals
  def bools_to_intervals(arr)
    last = 0
    l = arr.each_with_index.inject([]) do |a,(j,i)|
      if j==true or j==1
        a.push(1)
        last+=1 if i>0
      else
        a[last]+=1
      end
      a
    end
    l
  end

  def bools_to_durations(arr, default_dur=1.0, rhythm_map=nil)
    intervals = bools_to_intervals(arr)
    if rhythm_map
      ints_to_lengths(intervals, rhythm_map)
    else
      intervals.map {|v| v / (arr.length / default_dur)}
    end
  end

  def parse_binary(val, default_dur=1.0, rhythm_map=nil)
    if val.is_a?(Integer)
      bools_to_durations(val.to_s(2).split("").map{|b| b=="1" ? true : false }.flatten, default_dur, rhythm_map)
    elsif val.is_a?(String)
      bools_to_durations(val.bytes.map {|v| v.to_s(2).split("").map{|b| b=="1" ? true : false } }.flatten, default_dur, rhythm_map)
    elsif val.is_a?(Array) or val.is_a?(SonicPi::Core::RingVector)
      bools_to_durations(val,default_dur,rhythm_map)
    else
      raise "Not that shit!"
    end
  end

  # Tonnetz moves
  def get_move(move,triad)
    moves = {
      "l": [[1,-1],[5,1]],
      "p": [[3,-1],[3,1]],
      "r": [[5,2],[1,-2]]
    }
    if triad.is_major_chord?
      moves[move.to_sym][0]
    else
      moves[move.to_sym][1]
    end
  end

# Apply tonnetz moves
def apply_moves(moves,triad)
  move_set = moves.split(" ")
  new_triads = []
  triad[:hpcs] = triad[:hpcs].sort_by {|h| h.cpc } # Sort triad by chromatic pitches
  test_dgrs = triad.get_chord_degrees
  if test_dgrs # If this fails chord is not suitable triad?
    move_set.each do |t_moves|
      triad_moves = t_moves.split("")
      new_triad = triad.deep_clone
      triad_moves.each do |move|
        if ["p","l","r"].include?(move) # Ignore all other moves
          t_move = get_move(move,new_triad)
          dgrs = new_triad.get_chord_degrees
          x = dgrs.index(t_move[0])
          # Create new triad
          new_note = new_triad[:hpcs][x][:note]+t_move[1]
          temp_h = midi_to_pc(new_note,new_triad[:hpcs][x][:key],new_triad[:hpcs][x][:scale])
          new_triad[:hpcs][x][:note] = new_note
          new_triad[:hpcs][x][:pc] = temp_h[:pc]
          new_triad[:hpcs][x][:octave] = temp_h[:octave]
          new_triad[:hpcs][x][:add] = temp_h[:add]
          # Sort new triad to find new root
          new_triad[:hpcs] = new_triad[:hpcs].sort_by {|h| h.cpc }
          new_triad[:notes] = new_triad[:hpcs].map {|h| h[:note] }
          new_triad[:pcs] = new_triad[:hpcs].map {|h| h[:pc] }
        end
      end
      new_triads << new_triad
    end
    new_triads
  else
    [triad]
  end
end

def cardinal_move(move)
  mapping = {
    "s"=>"p",
    "e"=>"l",
    "w"=>"r",
    "SE"=>"lrp",
    "es"=>"lr",
    "se"=>"pr",
    "SW"=>"rlp",
    "sw"=>"pl",
    "ws"=>"rl",
    "n"=>"lpr",
    "ne"=>"lp",
    "nw"=>"rp"
  }
  mapping[move]
end

# Voice leading from: https://gist.github.com/xavriley/1ea12a3d319dfcf86152

# squish things into a single octave for comparison
# between chords and sort from lowest to highest
def octave_transform(input_chord, root)
  input_chord.map {|x| root + (x%12) }.sort
end

# get the distances between the notes
def t_matrix(chord_a, chord_b)
  root = chord_a.first
  z = octave_transform(chord_a, root).zip(octave_transform(chord_b, root))
  z.map {|a,b| b - a }
end

def voice_lead(chord_a, chord_b)
  # get mapping of notes in chord a
  # to the sorted version of the chord a
  root = chord_a.first

  a_leadings = chord_a.map {|x|
    [x, octave_transform(chord_a, root).index(root + (x%12))]
  }
  t_matrix = t_matrix(chord_a, chord_b)
  b_voicing = a_leadings.map {|x,y|
    x + t_matrix[y] if t_matrix[y] # Bad fix for chords of different sizes
  }
  b_voicing.compact
end

end
end
