# Example of using markov chain (after the Markov class)
# Markov source from https://github.com/samaaron/sonic-pi/issues/1029
class Markov
  def initialize(source, order=1, start=nil)
    @source = source
    @order = order || 1
    # prevent choosing order greater than length of melody
    if @order > @source.length - 1 then
      @order = @source.length - 1
    end
    reset(start)
  end
  
  def look
    @look.first
  end
  
  def reset(start=nil)
    # start at random position
    # populate @look with list of length (order)
    # this even works with zero-order
    start ||= SonicPi::Core::SPRand.rand_i!(@source.length - (@source.is_a?(SonicPi::Core::RingVector) ? 0 : @order))
    @look = []
    (start .. start + @order - 1).each do |i|
      @look.push(@source[i])
    end
    look
  end
  
  def chains
    @chains ||= begin
      links = {}
      (0 .. @source.length - (@source.is_a?(SonicPi::Core::RingVector) ? 0 : @order) - 1).each do |i|
        rule = []
        (i .. i + @order - 1).each do |j|
          rule.push(@source[j])
        end
        result = @source[i + @order]
        links[rule] ||= []
        if rule and result then
          links[rule].push(result)
        end
      end
      links
    end
  end
  
  def next
    out = look
    words = chains[@look]
    @look.shift
    if words then
      r = SonicPi::Core::SPRand.rand_i!(words.length)
      @look.push(words[r])
    end
    out
  end
end

def markov(source, order=1, start=nil)
  Markov.new(source, order, start)
end


# frere jacques in ziffers
n = zparse("|:q1231:|:q34h5:|@:e5654q31:|:q1-5+h1:@|")

notes = zparams(n, :note)
sleeps = zparams(n, :sleep)
notesAndLengths = notes.zip(sleeps)

chain = markov(notesAndLengths)

loop do |n|
  a = chain.next || chain.reset
  play a[0], attack: 0.1, release: 0.1, amp: 1
  sleep a[1]
end