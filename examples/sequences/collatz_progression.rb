load "~/ziffers/ziffers.rb"

use_synth :piano

def collatz n
  Enumerator.new do |enum|
    while n > 1
      n = n % 2 == 0 ? n / 2 : 3 * n + 1
      enum.yield n
    end
  end
end

e = collatz 987654321

loop do
  zplay "e"+e.next.to_s.split("").join(" ")
end
