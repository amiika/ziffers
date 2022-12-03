load "~/ziffers/ziffers.rb"

# Good 'old' way to use enumerations

def fibonacci
  Enumerator.new do |y|
    a = b = 1
    while true
      y << a
      a, b = b, a + b
    end
  end
end

enum = fibonacci

live_loop :fibonacci_chords do
  zplay enum, duration: 0.5, parse_chord: true
end
