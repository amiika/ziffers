# Requires ziffers.rb

# Ziffers keyboard - Always on key & scale

# These settings work with VMPK defaults using "QWERTYUIOP"-keys to play
use_bpm 60
use_synth :beep
startNote = 60 # Change this to start degrees from other key. Q-button using VMPK.
playKey = :c
playScale = :mixolydian
metronome = true
waitBeats = 5.0 # Waits as many silent beats to print ziffers notation & starts over

define :init do
  set :on_time, 0
  set :off_time, 0
  set :noteLength, 0
  set :deg, 0
  set :song, ""
end

s = (scale startNote, :major, num_octaves: 2).to_a # Dont change. This scale is used to map midi notes to degrees

init

live_loop :tick do
  use_debug false
  synth :pluck, note: 55, release: 0.01, amp: 0.5 if metronome
  sleep 1
  if get(:on_time)!=0
    diffTime = Time.now.to_f-get(:on_time)
    if diffTime>waitBeats
      setDegree(get(:deg),get(:off_time)) # Set last degree based on off_time
      print get(:song)
      init # Start from beginning after 5 empty beats
    end
  end
end

define :parse_sync_address do |address|
  v = get_event(address).to_s.split(",")[6]
  if v != nil
    return v[3..-2].split("/")
  else
    raise "Could not parse midi address"
  end
end

live_loop :playSong do
  use_real_time
  stop
  n = zparse song
  zplay n
  sleep (zbeats n)+1
end

live_loop :midi_piano_on do
  use_real_time
  note, vol = sync "/midi/*/*/*/note_*"
  res = parse_sync_address "/midi/*/*/*/*"
  event = res[4]
  deg = ((s.index note)+1)
  print note.to_s+ " -> "+deg.to_s
  
  if deg!=nil then
    case event
    when "note_on" then
      zplay deg, key: playKey, scale: playScale
      if get(:on_time)==0 then # On first note
        set :on_time, Time.now.to_f
        set :deg, deg
      else
        setDegree(deg, nil) # Set degree and calculate note length
        set :on_time, Time.now.to_f
      end
    when "note_off" then
      set :off_time, Time.now.to_f
    end
  end
end

def setDegree(deg, off_time)
  diffTime = off_time!=nil ? off_time-get(:on_time) : Time.now.to_f-get(:on_time)
  beatTimes = diffTime/current_beat_duration
  roundedTime = defaultDurs.values.min { |a,b| (a-beatTimes).abs <=> (b-beatTimes).abs }
  if get(:noteLength)!=roundedTime then
    set :noteLength, roundedTime
    defaultDurs.key(roundedTime)
    set :song, get(:song)+defaultDurs.key(roundedTime).to_s
  end
  set :song,  get(:song)+get(:deg).to_s
  set :deg, deg
end