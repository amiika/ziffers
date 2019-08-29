load "~/ziffers/ziffers.rb"

Ziffers.setZeroBased true

def asum(a,n,d)
  # https://en.wikipedia.org/wiki/Arithmetic_progression
  a+(n-1)*d
end

100.times do |n|
  zplay asum(2456,n+1,7).to_s
end