module Ziffers
  module Enumerables

    def create_ruleset(n)
      rules = Hash.new
      return rules if n > 255
      binary = "%08b" % n
      8.times do |i|
        key = "%03b" % i
        rules[key] = binary[7-i].to_i
      end
      return rules
    end

    def mutate(gen, rules)
      next_gen = []
      rules = create_ruleset(rules) if rules.is_a?(Integer)
      gen = gen.split("") if gen.is_a?(String)
      gen.each_with_index do |s,i|
        left = i > 0 ? i - 1 : gen.length - 1
        right = i < gen.length - 1 ? i + 1 : 0
        pattern = "#{gen[left]}#{gen[i]}#{gen[right]}"
        next_gen[i] = rules[pattern]
      end
      return next_gen
    end

    def boolean_cells(gen, rules=nil)
      automata(gen, rules, nil, true)
    end

    def live_cells(gen, rules=nil)
      automata(gen, rules)
    end

    def dead_cells(gen, rules=nil)
      automata(gen, rules, true)
    end

    def automata(gen, rules=nil, dead=nil, booleans=nil)
      Enumerator.new do |y|

        if !rules or rules.is_a?(Integer)
          rules = create_ruleset(rules ?  rules : rrand_i(1,255))
        elsif !rules.is_a?(Hash)
          raise "Automata rule must be number between 1-255"
        end

        if gen.is_a?(String)
          if gen.count("a-zA-Z") > 0
            gen = gen.unpack("B*")[0].split("").map{|n| n.to_i }
          else
            gen = gen.split("").map{|n| n.to_i }
          end
        elsif gen.is_a?(Integer)
          gen = gen.to_s(2).split("").map{|n| n.to_i }
        elsif gen.is_a?(SonicPi::Core::RingVector)
          gen = gen.map{|v| v ? 1 : 0}
        end

        old_gen = []
        next_gen = []
        while gen != old_gen
          old_gen = gen.dup
          gen.length.times do |i|
              left = i > 0 ? i - 1 : gen.length - 1
              right = i < gen.length - 1 ? i + 1 : 0
              pattern = "#{gen[left]}#{gen[i]}#{gen[right]}"
              next_gen[i] = rules[pattern]
            if booleans
              y << (next_gen[i] == 1)
            elsif next_gen[i] == 1
              y << (dead ? nil : i)
            else
              y << (dead ? i : nil)
            end
          end
          gen = next_gen
        end
      end
    end

    def gen_index_ones(gen)
      gen.map.with_index {|v,i| v==0 ? nil : i  }.compact
    end

    def gen_index_zeros(gen)
      gen.map.with_index {|v,i| v==1 ? nil : i+1  }.compact
    end

    def gen_space_ints(arr)
      last = 0
      last_obj = arr[0]
      l = arr.each_with_index.inject([0]) do |a,(j,i)|
        if j == last_obj
          a[last]+=1
        else
          a.push(1)
          last+=1
          last_obj = j
        end
        a
      end
      l
    end

    def markov_generator(chain)
      chain = chain.to_s.split("").map {|v| v.to_i(36) }
      nums = chain.max+1
      i = chain[-1]
      mm = to_pc_mm chain, nums
      Enumerator.new do |y|
        while true
          i = next_idx mm, i
          y << i
        end
      end
    end

    # Shorthand function to create the markov chain
    def to_pc_mm(degrees, mm=8, init=false)
      # Length of the markov matrix
      length = mm.is_a?(Integer) ? mm : mm.length
      # Init with random matrix if mm=integer
      mm = Array.new(length) { Array.new(length, init ? 1.0/length : 0.0) } if mm.is_a?(Integer)
      # Treat integer as a markov chain: 121 = 1->2, 2->1
      degrees.each_with_index do |d,i|
        row = d % length
        # Treat int as 'ring': 12 = 1->2->1
        next_d = degrees[(i+1)%degrees.length]
        column = next_d % length
        mm[row][column] += 1.0
      end
      # Normalize the resulted matrix
      normalize mm
    end

    # Normalizes markov chain
    def normalize(mm)
      mm.length.times do |row|
        pp = 0.0
        mm[row].each do |p|
          pp += p
        end
        mm[row].length.times do |i|
          if pp == 0.0 then
            #puts "warning: no transition defined for row #{row+1}!" if i == 0
            mm[row][i] = 1.0/mm[row].length
          else
            mm[row][i] /= pp
          end
        end
      end
      mm
    end

    # Get next id
    def next_idx(mm,n)
      r = rand
      pp = 0
      row = mm[n]
      i = row.index do |p|
        pp += p
        pp > r
      end
      until i
        r = rrand_i 0, row.length-1
        row[r] = 1.0-rand(0.5)
        i = r if r!=n
      end
      i
    end

    def fibonacci
      Enumerator.new do |y|
        a = b = 1
        while true do
          y << a
          a, b = b, a + b
        end
      end
    end

    def pi
      Enumerator.new do |y|
        q, r, t, k, n, l = 1, 0, 1, 1, 3, 3
        while true do
          if 4*q+r-t < n*t then
            y << n
            nr = 10*(r-n*t)
            n = ((10*(3*q+r)) / t) - 10*n
            q *= 10
            r = nr
          else
            nr = (2*q+r) * l
            nn = (q*(7*k+2)+r*l) / (t*l)
            q *= k
            t *= l
            l += 2
            k += 1
            n = nn
            r = nr
          end
        end
      end
    end

    # http://www.cs.utsa.edu/~wagner/pi/ruby/pi_works.html

    def phi
      Enumerator.new do |y|
        k, a, b, a1, b1 = 2, 2, 1, 3, 2
        while true do
          p, q, k = 1, 1, k+1
          a, b, a1, b1 = a1, b1, p*a+q*a1, p*b+q*b1
          d = a / b
          d1 = a1 / b1
          while d == d1
            y << d
            a, a1 = 10*(a%b), 10*(a1%b1)
            d, d1 = a/b, a1/b1
          end
        end
      end
    end

    # https://oeis.org/A001113
    def euler
      Enumerator.new do |y|
        k, a, b, a1, b1 = 2, 3, 1, 8, 3
        while true do
          p, q, k = k, k+1, k+1
          a, b, a1, b1 = a1, b1, p*a+q*a1, p*b+q*b1
          d = a / b
          d1 = a1 / b1
          while d == d1
            y << d
            a, a1 = 10*(a%b), 10*(a1%b1)
            d, d1 = a/b, a1/b1
          end
        end
      end
    end

  # https://oeis.org/A309600
  def a309600
  Enumerator.new do |y|
    a = 7
    i = 0
    y << 7 if i==0
    while true do
        b = (a + 3 * (9 * a ** 3 - 17)) % (10 ** (i + 2))
        y << (b - a) / (10 ** (i + 1))
        i+=1
        a = b
      end

    end
  end

    # https://oeis.org/A225410
    def a225401
    Enumerator.new do |y|
      a = 7
      i = 0
      y << 7 if i==0
      while true do
          b = (a + 3 * (9 * a ** 3 - 7)) % (10 ** (i + 2))
          y << (b - a) / (10 ** (i + 1))
          i+=1
          a = b
        end
      end
    end


    # https://oeis.org/A225408
    # 10-adic integer x=.....8457 satisfying x^3 = -7.
    def a225408
    Enumerator.new do |y|
      a = 7
      i = 0
      y << 7 if i==0
      while true do
          b = (a + 7 * (a ** 3 + 7)) % (10 ** (i + 2))
          y << (b - a) / (10 ** (i + 1))
          i+=1
          a = b
        end
      end
    end

    # https://oeis.org/A225406
    # Digits of the 10-adic integer 9^(1/3).
    def a225406
    Enumerator.new do |y|
      a = 9
      i = 0
      y << 9 if i==0
      while true do
          b = (a + 3 * (a ** 3 - 9)) % (10 ** (i + 2))
          y << (b - a) / (10 ** (i + 1))
          i+=1
          a = b
        end
      end
    end

    # https://oeis.org/A000695
    def bruijn
    Enumerator.new do |n|
      x = 0
      while true do
        n << x
        y = ~(x << 1)
        x = (x - y) & y
      end
    end
  end

  # https://oeis.org/A059905
  def bruijn_walk
    Enumerator.new do |y|
      n = 0
      while true do
          y << (0..n.bit_length/2).to_a.map { |i| (n >> 2 * i & 1) << i}.reduce(:+)
          n+=1
        end
      end
    end

    # https://www.mathpages.com/home/kmath312/kmath312.htm
    def reverse_sum(n=17509097067,base=10)
      Enumerator.new do |y|
        while true do
          y << n
          n = (n.to_i+n.to_s.reverse.to_i).to_s(base).to_i
        end
      end
    end

    # Collatz conjecture (Also known as hailstone numbers)
    # https://en.wikipedia.org/wiki/Collatz_conjecture
    def collatz(orig=987654321)
      Enumerator.new do |enum|
        n = orig
        while n > 1
          n = n % 2 == 0 ? n / 2 : 3 * n + 1
          enum.yield n
        end
      end
    end

    # https://en.wikipedia.org/wiki/Arithmetic_progression
    def aprog(a=1,x=2,e=Float::INFINITY)
      (a..e).lazy.collect {|n| a+(n-1)*x }
    end

    # https://en.wikipedia.org/wiki/Geometric_progression
    def gprog(a=1,r=2,e=Float::INFINITY)
      (a..e).lazy.collect {|n| a * r ** (n-1) }
    end

    # https://en.wikipedia.org/wiki/Quadratic_function
    def quadratic(a,b,c,s=0,e=Float::INFINITY)
      (s..e).lazy.collect {|n| a*(n**2)+(b*n)+c }
    end

    # https://en.wikipedia.org/wiki/Polynomial
    def polynomial(coef,s=0,e=Float::INFINITY)
      s_coef = coef.sort.reverse
      (s..e).lazy.collect {|x| polyval(x,coef.reverse).to_i }
    end

    def polyval(x, coef)
      sum = 0
      coef = coef.clone
      while true
          sum += coef.shift
          break if coef.empty?
          sum *= x
      end
      return sum
    end

    def primes(e=Float::INFINITY)
      (2..e).lazy.reject {|n| (2..Math.sqrt(n)).any?{ |j| n % j == 0 }}
    end

    # https://oeis.org/A005132
    def recaman
      Enumerator.new do |y|
        s = []
        0.step do |i|
          x = i == 0 ? 0 : s[i-1]-i
          s << ((x>=0 and !s.include? x) ? x : s[i-1]+i)
          y << s[i]
        end
      end
    end

    # https://oeis.org/A005185
    def hoffQ
      Enumerator.new do |y|
        q = []
        0.step do |i|
          q << (i<2 ? 1 : q[i - q[i - 1]] + q[i - q[i - 2]])
          y << q[i]
        end
      end
    end

    # https://oeis.org/A002487
    def sterns
      Enumerator.new do |y|
        a=[1,1]
        0.step do |i|
          y << (i>0 ? a[i] : 0)
          a << a[i]+a[i+1] << a[i+1]
        end
      end
    end

    # https://oeis.org/A000265
    def frac2
      Enumerator.new do |y|
      1.step do |n|
        n>>=1 while n%2==0
        y << n
      end
      end
    end

    # http://oeis.org/A010060
    def thue_morse(base=2,mod=base)
      (0..Float::INFINITY).lazy.collect {|n| n.to_s(base).split("").map{|v| v.to_i}.reduce(0, :+) % mod } #.count('1') % base}
    end

    # https://oeis.org/A001316
    def dress(e=Float::INFINITY)
      (0..e).lazy.collect {|n| A001316_recursion(n) }
    end

    # Dress sequence https://oeis.org/A001316
    def A001316_recursion(n)
      return n+1 if n <= 1
      A001316(n/2) << n%2
    end

    def inventory(e=Float::INFINITY)
      (0..e).lazy.collect {|n| A342585(n) }
    end

  # Inventory sequence: http://oeis.org/A342585
  def A342585(n)
    values = []
    current_val = 0
    new_val = 0
    n.times do |i|
      new_val = values.count(current_val)
      values.append(new_val)
      current_val = new_val == 0 ? 0 : current_val+=1
    end
    new_val
  end

    # Van Ecks sequence: http://oeis.org/A181391
    def vanecks
    Enumerator.new do |y|
      last = 0
      counts = {}
      0.step do |i|
        current = last
        last = i - (counts[current] || i)
        counts[current] = i
        y << current
      end
    end
  end

    # https://oeis.org/A030101
    def binrev(base=2)
      Enumerator.new do |y|
      0.step do |n|
        y << n.to_s(base).reverse.to_i(base)
      end
      end
    end

    # https://oeis.org/A000217
    def triangular
    Enumerator.new do |y|
    s = []
    0.step do |i|
      s[i]=i+1
      y << s.inject(&:+)
    end
    end
    end

    # https://oeis.org/A001006
    def motzkin_numbers
      Enumerator.new do |y|
        a, b, c = 1, 1, 1
        y << a
        y << b
        (2..Float::INFINITY).each do |i|
          c, b, a = ((2 * i + 1) * c + (3 * i - 3) * a) /
          (i + 2), a, c
          y << c
        end
      end
    end

    # Markov source code from https://github.com/samaaron/sonic-pi/issues/1029
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

    def markov_analyzer(source, order=1, start=nil)
      Enumerator.new do |y|
        chain = Markov.new(source, order, start)
        while true
          y << (chain.next || chain.reset)
        end
      end
    end

  end
end
