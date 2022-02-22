module Ziffers
  module Defaults

    def int_to_length(val)
      # 0.125, 0.25, 0.375, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0
      k = @@rhythm_keys[val%@@rhythm_keys.length]
      @@default_durs[k.to_sym]
    end

    def get_default_opts
      @@default_opts
    end

    def list_dur_chars
      @@default_durs.to_a
    end

    def set_default_opts(opts)
      @@default_opts.merge!(opts)
    end

    def merge_synth_defaults
      @@default_opts.merge!(Hash[current_synth_defaults.to_a])
    end

    @@default_opts = {
      :key => :c,
      :scale => :major,
      :release => 1.0,
      :sleep => 1.0,
      :synth => :piano
    }

      @@rhythm_keys = ['e','q','q.','h','h.','w','w.','d','d.','l']

      @@default_durs = {
              'm': 8.0, # 15360 ticks
              'k': 5.333, # 10240 ticks
              'l': 4.0, # 7680
              'd.': 3.0, #
              'p': 2.667, # 5120
              'd': 2.0, # 3840
              'w.': 1.5,
              'c': 1.333, # 2560
              'w': 1.0, # 1920
              'h.': 0.75,
              'y': 0.667, # 1280
              'h': 0.5, # 960 - 1/2
              'q.': 0.375,
              'n': 0.333, # 640
              'q': 0.25, # 480 - 1/4
              'e.': 1.875,
              'a': 0.167, # 320
              'e': 0.125, # 240 - 1/8
              'f': 0.083, # 160
              's': 0.0625, # 120 - 1/16
              'x': 0.042, # 80
              't': 0.031, # 60 - 1/32
              'g': 0.021, # 40
              'u': 0.016, # 30 - 1/64
              'j': 0.010, # 20
              'o': 0.005, # 10 - 1/128
              'z': 0.0 # 0
            }

    end
end
