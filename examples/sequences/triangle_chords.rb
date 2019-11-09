load "~/ziffers/ziffers.rb"

def triangles
  Enumerator.new do |y|
    s = []
    0.step do |i|
      s[i]=i+1
      y << s.inject(&:+)
    end
  end
end

tr = triangles

loop do
  zplay tr.next.to_s, chord_sleep: 0.125
end