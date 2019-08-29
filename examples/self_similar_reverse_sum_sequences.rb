load "~/ziffers/ziffers.rb"

# https://www.mathpages.com/home/kmath312/kmath312.htm
def reverse_sum(n,base=10)
  (n.to_i+n.to_s.reverse.to_i).to_s(base).to_i
end

#n=17509097067
n=589865754
Ziffers.setZeroBased true

100.times do
  zplay n.to_s, lengths: {0=>"q", 1=>"e",2=>"e",3=>"q",4=>"e",5=>"q",6=>"q", 7=>"q",8=>"e",9=>"q"}
  print n
  n = reverse_sum n
end
