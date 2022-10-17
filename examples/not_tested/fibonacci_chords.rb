load "~/ziffers/ziffers.rb"

# Good 'old' way to use enumerations

def fibonacci
  Enumerator.new do |y|
    a = b = 1
    loop do
      y << a
      a, b = b, a + b
    end
  end
end

enum = fibonacci

live_loop :fibonacci_chords do
  zplay enum.next.to_s, duration: 0.5
end
