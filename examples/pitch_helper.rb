require "~/ziffers/ziffers.rb"

# Have a perfect pitch? Find out!
# This pling plong tool can also help you to:
# Relate sound to numbers or note names
# Relate note names to pcs

# Configuration
pitch_key = :C # Choose key C-B
pitch_scale = :chromatic # Scale :chromatic, :major, :minor, :major_pentatonic, :minor_pentatonic
pitch_octave = 0 # Starting octave
play_scale = true # "Preview" scale before starting
show_degrees = false # Show degrees instead of pcs
number_of_octaves = 1 # More octaves means more fun?
speed = 1.0 # Waiting time for the next note
t_synth = :piano # Change synth

# Code starts here
notes = scale pitch_key, pitch_scale
zplay "q (0..#{(notes.length-2)*number_of_octaves})<mirror>", synth: t_synth, octave: pitch_octave, scale: pitch_scale, key: pitch_key if play_scale

live_loop :run_trainer do
  sleep speed
  random = (rrand_i 0, (notes.length-2)*number_of_octaves)
  r = zparse "{#{random}}", synth: t_synth, octave: pitch_octave, scale: pitch_scale, key: pitch_key
  zplay r
  sleep speed
  if show_degrees
    print "Scale degree: #{r[0].dgr}"
  else
    print "Pitch class:  #{r[0].pc}"
  end
  print "Note name:    #{r[0].note_name}"
end
