# Play ziffers using keyboard
# On windows: https://in-thread.sonic-pi.net/t/connecting-sonic-pi-to-virtual-midi-piano-keyboard-on-windows-10/176

live_loop :midi_piano do
  use_real_time
  note, velocity = sync "/midi/loopmidi_port/0/1/note_on"
  print note
  zmidi note, {sample: :ambi_glass_rub, key: :e}, {rateBased: true}
end