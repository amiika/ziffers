load "~/ziffers/ziffers.rb"

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
  
  z1 pi, sleep: 0.125
  