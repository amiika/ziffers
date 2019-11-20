module Ziffers
  module Enumerables

    def fibonacci
      Enumerator.new do |y|
        a = b = 1
        loop do
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

    # TODO: Not working yet.
    def square(num)
      Enumerator.new do |y|
        x = (1.0+(1.0/(num))).rationalize
        z = ((x.numerator + num * x.denominator).to_f / (x.numerator + x.denominator).to_f).rationalize
        a = x.numerator
        b = x.denominator
        a1 = z.numerator
        b1 = z.denominator
        k = num
        while true do
          p, q, k = 1, num, k+1
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

    # https://www.mathpages.com/home/kmath312/kmath312.htm
    def reverse_sum(n=17509097067,base=10)
      Enumerator.new do |y|
        while true do
          y << n
          n = (n.to_i+n.to_s.reverse.to_i).to_s(base).to_i
        end
      end
    end

    def collatz(n=987654321)
      Enumerator.new do |enum|
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
    def gproq(a=1,r=2,e=Float::INFINITY)
      (a..e).lazy.collect {|n| a * r ** (n-1) }
    end

    # https://en.wikipedia.org/wiki/Quadratic_function
    def quadratic(a,b,c,s=0,e=Float::INFINITY)
      (s..e).lazy.collect {|n| a*(n**2)+(b*n)+c }
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

  end
end
