load "~/ziffers/ziffers.rb"

Ziffers.setZeroBased true

def qsum(a,b,c,n)
  # https://en.wikipedia.org/wiki/Quadratic_function
  a*(n**2)+(b*n)+c
end

100.upto(120) do |n|
  zplay qsum(1,0,3,n).to_s
end