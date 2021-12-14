require_relative "./defaults.rb"

module Ziffers
  module Generators
    include Ziffers::Defaults

  def ints_to_lengths(val)
    val.map {|n| int_to_length(n) }
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
      s_counter+=1
      if ((i % major==0) || (i % minor==0) || (third && (i % third==0)))
        s_start+=1
        s_counter = 0 if s_start==2
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

 # Euclidean generators (Spread to integers)

  def bools_to_seq(arr)
    last = 0
    l = arr.each_with_index.inject([]) do |a,(j,i)|
      if j
        a.push(1)
        last+=1 if i>0
      else
        a[last]+=1
      end
      a
    end
    l
  end

  def spreader(r, l=1.0)
    i = 0
    arr = []
    r.each_with_index.map do |x,j|
      i+=1  if x and j>0
      if !arr[i]
        arr.push(l/r.length)
      else
        arr[i]+=l/r.length
      end
    end
    arr
  end

  def bin_lengths val
    spreader(val.to_s(2).split("").map{|b| b=="1" ? true : false }.flatten)
  end

  # Slonimsky scales: https://slonimsky.netlify.app/
  def slonimsky(nodes, interpolations, divisions=1)
    return [] if (nodes <= 0)
    nodes.times.collect { |i| [i * divisions] + interpolations.map { |x| (i * divisions) + x }}.flatten
  end

end
end
