use_synth :piano

def testsingledegrees
  (scale :gong).reflect.each do |k|
    [1,6].each do |d|
      zplay d, key: 40+k, scale: :blues_minor
      sleep 0.1
    end
  end
end

def testarraydegrees
  zplay [4,4,3,3,2,2,3,3,4,4,3,3,2,2,3,3], key: :c, scale: :chromatic, sleep: 0.12
  zplay (scale :gong).reflect.to_a,  key: 60, scale: :blues_minor
end

def testzplay
  # frere jacques
  zplay("|:q1231:|:q34h5:|@:e5654q31:|:q1-5+h1:@|")
  # ode to joy
  zplay("|:q3345|5432|1123|;q32h2;q21h1:|q2231|2e34q31|2e34q32|q12h-5|+q3345|5432|1123|21h1|")
  # twinkle twinkle
  zplay("q115566h5q443322h1 *|: q554433h2 :|*")
  # row row
  zplay("|:q.1.1|q1e2q.3|3e2q3e4|h.5|e888555333111|q5e4q3e2|h.1:|")
  # Test transposing degrees
  zplay("s12345678987654321",{scale: "major_pentatonic"})
  # Numbered loops
  zplay("|:1234:3|616|:4321:3|")
end

def testzdrums
  # Some drum sounds
  zdrums("1 2 3 4")
end

def testzsynth
  # Ski or die
  zsynth("h3q323 q ~0.1 3666 h5.3 q ~0.25 3666 53 q ~0.2 3232222",{synth:"chipbass"})
  # Chord synth test
  zsynth("|:C4 123 C3 234 C2 432 C1 123:|",{key: "e", scale: "mixolydian"})
end

def testzbin
  # Binaural twinkle
  m = zparse("q115566h5q443322h1 *|: q554433h2 :|*")
  with_synth :sine do
    zbin(m,{hz:10})
  end
end

def testrandom
  with_synth :beep do
    zplay("$ P? A0.? (1,2) P? A0.? (2,3) P? A0.? (3,4) $ [1,2,3] P? [4,5,6] P? [4,5,6] ~ ????????? ")
  end
end

def testzsample
  n = zparse("|:q1231:|:q34h5:|@:e5654q31:|:q1-5+h1:@|", {sample:  :ambi_drone, sustain: 0.25, key: "c1"}, defaultSampleOpts)
  zsample(n, {}, true)
  zsample("|:q1231:|:q34h5:|@:e5654q31:|:q1-5+h1:@|", {sample:  :ambi_drone, key: "c1", sustain: 0.25})
  zsample("h3q323 q ~0.1 3666 h5.3 q ~0.25 3666 53 q ~0.2 3232222",{sample: :ambi_piano, sustain: 0.25, key: "c"})
  zsample("q115566h5q443322h1 *|: q554433h2 :|*", sample: :ambi_glass_rub, rate: 2.1, amp: 0.2)
end

testsingledegrees
testarraydegrees
testzplay
testzsynth
testzdrums
testzbin
testrandom
testzsample
