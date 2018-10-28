# Requires loading or running ziffers.rb

use_debug false
use_midi_logging false

use_midi_defaults port: "casio_usb-midi", channel: 3

live_loop :test do
  zplay("%-3 i ???? ii e???? ????", key: :e3, scale: :octatonic, port: "casio_usb-midi", channel: 3)
  zplay("%-3 i ???? vi^7 e???? ???? vii ???? + v^7 ???? vi ???? iv^7 ???? ii ????", key: :e3, scale: :octatonic, port: "casio_usb-midi", channel: 3)
end

live_loop :tes2 do
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

live_loop :change do
  pc = rrand_i 1,127
  bank = rrand_i 0, 10
  print pc
  print bank
  midi_pc pc
  midi_cc 0, bank
  sleep 2
end