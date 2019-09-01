load "~/ziffers/ziffers.rb"

Ziffers.setZeroBased true

def gseq(a, r, n)
  # https://en.wikipedia.org/wiki/Geometric_progression
  a * r ** (n-1)
end

1.upto(20) do |n|
  zplay gseq(6,3,n).to_s(8), scale: :minor, lengths: {0=>"h",1=>"q",2=>"h",3=>"q",4=>"e",5=>"e",6=>"q",7=>"q",8=>"e"}
end
