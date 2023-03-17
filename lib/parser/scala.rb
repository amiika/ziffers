require "prime"

def cents_to_semitones(cents)
  """Tranform cents to semitones"""
  cents = [0.0] + cents unless cents[0] == 0.0
  semitone_scale = []
  cents.each_with_index do |cent, i|
    break if i == cents.length - 1
    semitone_interval = (cents[i + 1] - cent) / 100.0
    semitone_scale << semitone_interval
  end
  semitone_scale
end

def ratio_to_cents(ratio)
  # Transform ratio to cents
  (1200.0 * Math.log2(ratio.to_f))
end

def monzo_to_cents(monzo)
  # Calculate the prime factors of the indices in the monzo
  max_index = monzo.length
  primes = Prime.first(max_index + 1)

  # Product of the prime factors raised to the corresponding exponents
  ratio = 1

  (0...max_index).each do |i|
    ratio *= primes[i] ** monzo[i]
  end

  # Frequency ratio to cents
  1200 * Math.log2(ratio)

end
