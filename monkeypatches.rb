module RangeZiffers
  include SonicPi::Lang::WesternTheory
  def to_z
    self.to_a.map {|degree| get_ziff(degree) }
  end
end

Range.include RangeZiffers

module NoteHelper
  include SonicPi::Lang::WesternTheory
  def to_h
    (note_info self).to_h
  end
end

Integer.include NoteHelper

class SonicPi::Scale
  def self.patch(scales)
    scales.each { |name, intervals|
      self::SCALE[name] = intervals unless self::SCALE.key? name
    }
  end

  def initialize(tonic, name, num_octaves=1)
    if name.is_a?(Array)
      intervals = name
      name = :custom
    else
      name = name.to_sym
      intervals = SCALE[name]
    end
    raise InvalidScaleError, "Unknown scale name: #{name.inspect}" unless intervals
    intervals = intervals * num_octaves
    current = SonicPi::Note.resolve_midi_note(tonic)
    res = [current]
    intervals.each do |i|
      current += i
      res << current
    end

    @name = name
    @tonic = tonic
    @num_octaves = num_octaves
    @notes = res
    super(res)
  end

end

class SonicPi::Chord
  def self.patch(chords)
    chords.each { |name, intervals|
      unless self::CHORD.key? name.to_sym
        self::CHORD[name.to_sym] = intervals
        self::CHORD_LOOKUP[name.to_sym] = intervals
        self::CHORD_NAMES.append(name)
      end
    }
  end
end

#Missing scales based on: https://www.newjazz.dk/Compendiums/scales_of_harmonies.pdf
scales = lambda {
  ionian1s = [1,2,1,2,2,2,2]
  ionian5s = [2,2,1,3,1,2,1]
  ionian6b = [2,2,1,2,1,3,1]
  {
    # Family 2
    :ionian1s=>ionian1s,
    :dorian7s=>ionian1s.rotate(1),
    :phrygian6s=>ionian1s.rotate(2),
    :lydian5s=>ionian1s.rotate(3),
    :mixolydian4s=>ionian1s.rotate(4),
    :aeolian3s=>ionian1s.rotate(5),
    :locrian2s=>ionian1s.rotate(6),
    # Family 3
    :ionian5s=>ionian5s,
    :dorian4s=>ionian5s.rotate(1),
    :phrygian3s=>ionian5s.rotate(2),
    :lydian2s=>ionian5s.rotate(3),
    :mixolydian1s=>ionian5s.rotate(4),
    :aeolian7s=>ionian5s.rotate(5),
    :locrian6s=>ionian5s.rotate(6),
    # Family 4
    :ionian6b=>ionian6b,
    :dorian5b=>ionian6b.rotate(1),
    :phrygian4b=>ionian6b.rotate(2),
    :lydian3b=>ionian6b.rotate(3),
    :mixolydian2b=>ionian6b.rotate(4),
    :aeolian1b=>ionian6b.rotate(5),
    :locrian7b=>ionian6b.rotate(6),
  }
}.call

chords = {
  # https://en.wikipedia.org/wiki/Minor_major_seventh_chord
  'mM7'=> [0, 3, 7, 11],
  # https://en.wikipedia.org/wiki/Augmented_major_seventh_chord
  'maj7+5'=> [0, 4, 8, 11],
  '6+5'=> [0, 4, 8, 9],
  # Missing altered chords: https://en.wikipedia.org/wiki/Altered_chord
  '7-5-3'=>[0, 3, 6, 10],
  '7+5+9'=>[0, 4, 8, 10, 14],
  '7-5-9'=>[0, 4, 6, 10, 13],
  '7-5+9'=>[0, 4, 6, 10, 14]
}

SonicPi::Scale.patch(scales)
SonicPi::Chord.patch(chords)

def zlog text
	File.open(ENV['HOME']+'/.sonic-pi/log/ziffers.log', 'w+') {|log|
		log.write text
	}
end
