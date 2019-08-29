load "~/ziffers/ziffers.rb"

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

def hoffQ
  Enumerator.new do |y|
    q = []
    0.step do |i|
      q << (i<2 ? 1 : q[i - q[i - 1]] + q[i - q[i - 2]])
      y << q[i]
    end
  end
end

print hoffQ.first(10)

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

print sterns.first(1000)

def binrev(n, base=2)
  # https://oeis.org/A030101
  return n.to_s(base).reverse.to_i(base)
end

def revsum(n, base=10)
  # 17509097067
  # https://www.mathpages.com/home/kmath312/kmath312.htm
  return (n+n.to_s.reverse.to_i).to_s(base).to_i
end

print revsum(132435469)

def dress(n)
  # https://oeis.org/A001316
  return 2*n.to_s(2).count("1")
end

def frac2(n)
  # https://oeis.org/A000265
  n>>=1 while n%2==0
  return n
end


#print sb.first(100)

#zplay sterns.first(100)

def normDiv(numbers, min, max)
  nmin = numbers.min
  nmax = numbers.max
  numbers.map {|n| min + (n - nmin) * (max - min) / (nmax - nmin)}
end

def normMod(num,pmin,pmax)
  num.map {|o| pmin + o % (pmax - pmin + 1) }
end

def normDur(num)
  nmin = num.min
  nmax = num.max
  num.map {|o| (o.to_f-nmin)/(nmax-nmin)+0.25 }
end

#a = recaman(200)
#b = normDur(a)
#play_pattern_timed normMod(a,60,80),b


