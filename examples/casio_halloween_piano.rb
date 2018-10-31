# Requires loading or running ziffers.rb

use_bpm 65
use_debug false
use_midi_logging false

use_midi_defaults port: "casio_usb-midi", channel: 3

live_loop :low do
  zplay("[%-3 i ???? iv e???? ???? v q???? iv h??,%-3 i ???? vi^7 e???? ???? vii ???? + v^7 ???? vi ???? iv^7 ???? ii ????]", key: :e3, scale: :octatonic, port: "casio_usb-midi", channel: 3)
end

live_loop :high do
  zplay("[%+3 i e???? ???? ii ????, %+2 iv w ? iii ?]", key: :e, scale: :octatonic, port: "casio_usb-midi", channel: 3)
end

live_loop :trough do
  sleep rrand_i 15,30
  36.upto(96) do |i|
    sleep 0.125
    midi i, sustain: 0.25
  end
  96.downto(36) do |i|
    sleep 0.125
    midi i, sustain: 0.25
  end
end

live_loop :change_sound do
  pc = rrand_i 1,127
  bank = rrand_i 0, 96
  print pc
  print bank
  midi_pc pc
  midi_cc 0, bank
  sleep 2
end

live_loop :change_pan do
  midi_cc 10, (rrand_i 0,127)
  sleep 0.5
end
