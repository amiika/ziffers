module Ziffers
  module Defaults

    def int_to_length(val,map=nil)
      if map
        map[val%map.length]
      else
        # ['e','q','q.','h','h.','w','w.','d','d.','l']
        # 0.125, 0.25, 0.375, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0
        k = @@rhythm_keys[val%@@rhythm_keys.length]
        @@default_durs[k.to_sym]
      end
    end

    def port(port_value)
      if !port_value
        @@default_opts.delete(:port)
      else
        @@default_opts[:port] = port_value
      end
    end

    def channel(channel_value)
      if !channel_value
        @@default_opts.delete(:channel)
      else
        @@default_opts[:channel] = channel_value
      end
    end

    def get_default_opts
      @@default_opts
    end

    def get_default(key)
      @@default_opts[key]
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

    @@default_port = nil

    @@default_opts = {
      :key => :c,
      :scale => :major,
      :duration => 0.25
    }

      @@rhythm_keys = ['e','q','q.','h','h.','w','w.','d','d.','l']

      @@default_durs = {
        "m..": 14.0,      # Double dotted maxima
        "m.": 12.0,       # Dotted maxima
        "m": 8.0,         # Maxima
        "l..": 7.0,       # Double dotted long
        "l.": 6.0,        # Dotted long
        "l": 4.0,         # Long
        "d..": 7/2.0,     # 3.5: Double dotted double whole
        "d.": 3.0,        # Dotted double whole
        "n": 8/3.0,       # 2.666: Triplet long
        "d": 2.0,         # Double whole
        "w..": 7/4.0,     # 1.75: Double dotted whole
        "w.": 3/2.0,      # 1.5: Double dotted whole
        "k": 4/3.0,       # 1.333: Triplet double whole
        "w": 1.0,         # Whole
        "h..": 7/8.0,     # 0.875: Double dotted half
        "h.": 3/4.0,      # 0.75: Dotted half
        "c": 2/3.0,       # 0.666: Triplet whole
        "h": 1/2.0,       # 0.5: Half
        "p": 1/3.0,       # 0.333: Triplet half
        "q..": 7/16.0,    # 0.4375: Double dotted quarter
        "q.": 3/8.0,      # 0.375: Dotted quarter
        "q": 0.25,        # Quarter
        "e..": 7/32.0,    # 0.2187: Double dotted eighth
        "e.": 3/16.0,     # 0.1875: Dotted eighth
        "g": 1/6.0,       # 0.1666: Triplet quarter
        "e": 1/8.0,       # 0.125: 8th note
        "s..": 7/64.0,    # 0.1093: Double dotted 16th
        "a": 1/12.0,      # 0.0833: Triplet 8th
        "s.": 3/32.0,     # 0.0937: Dotted 16th
        "s": 1/16.0,      # 0.0625: 16th note
        "t..": 7/128.0,   # 0.0546: Double dotted 32th
        "t.": 3/64.0,     # 0.0468: Dotted 32th
        "f": 1/24.0,      # 0.0416: Triplet 16th
        "t": 1/32.0,      # 0.0312: 32th note
        "u..": 7/256.0,   # 0.0273: Double dotted 64th
        "u.": 3/128.0,    # 0.0234: Dotted 64th
        "x": 1/48.0,      # 0.0208: Triplet 32th
        "u": 1/64.0,      # 0.0156: 64th note
        "o..": 7/512.0,   # 0.0136: Double dotted 128th
        "y": 1/96.0,      # 0.0104: Triplet 64th
        "o.": 3/256.0,    # 0.0117: Dotted 128th
        "o": 1/128.0,     # 0.0078: 128th note
        "j": 1/192.0,     # 0.0052: Triplet 128th
        "z": 0.0,         # 0
      }

      @@pitch_mappings = {
            :volca_drum => [0,1,3,5,8,10,15,18,20,25.6,26.9,28.3,29.9,31.6,33.5,35.5,37.6,39.9,42.3,44.9,47.6,50.4,53.4,56.4,59.7,63.1,66.6,70.2,74,78,82,86.2,90.6,95,99.7,104.4,109.3,114.3,119.5,124.8,130.3,135.8,141.5,147.4,153.4,159.5,165.8,172.2,178.8,185.4,192.3,199.2,206.3,213.5,220.9,228.4,236.1,243.9,251.8,259.8,268,276.4,284.9,293.5,302.2,311.1,320.1,329.3,338.6,348,357.6,367.3,377.2,387.2,397.3,407.6,418,428.5,439.2,450,461,472.1,483.3,494.7,506.2,517.8,529.6,541.5,553.6,565.6,578.1,590.6,603.2,615.9,628.8,641.8,655,668.3,681.7,695.3,709,722.9,736.8,751,765.3,779.6,794.2,808.8,823.7,838.6,853.7,868.9,884.3,899.8,915.5,931.2,947.2,963.2,979.4,995.7,1012,1029,1046,1062,1079,1097,1114,1131,1149,1167,1185,1202,1220,1239,1257,1276,1294,1313,1332,1351,1370,1390,1409,1429,1449,1469,1489,1509,1529,1550,1570,1591,1611,1633,1654,1675,1698,1718,1739,1762,1784,1806,1829,1850,1872,1896,1919,1942,1967,1989,2010,2032,2057,2082,2107,2133,2157,2179,2200,2224,2251,2277,2303,2331,2358,2382,2403,2424,2448,2476,2505,2534,2564,2595,2622,2645,2667,2688,2711,2738,2770,2801,2832,2865,2899,2931,2957,2980,3001,3021,3042,3065,3093,3158,3184,3204,3224,3265,3323,3352,3377,3399,3420,3440,3462,3485,3511,3563,3600,3621,3676,3694,3714,3771,3792,3810,3850,3934,3957,3976,3994,4011,4028,4046,4064,4164,4212,4230,4245,4326,4346,4362,4380,4398,4500]
      }

      def midi_to_cc_pitch(key, midi_note)

        arr = @@pitch_mappings[key] if key.is_a?(Symbol) and @@pitch_mappings[key]
        arr = key if key.is_a?(Array)
        if arr
          midi_hz = midi_to_hz midi_note
          cc_pitch = arr.each_with_index.min_by{|hz,cc| (midi_hz-hz).abs}
          cc_pitch[1]
        else
          raise "No valid pitch cc mapping"
        end
      end

    end
end
