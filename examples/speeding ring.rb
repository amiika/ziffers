require "~/ziffers/ziffers.rb"

n = zparse("q 333 444 222 666")

live_loop :test do
  with_fx :echo do
    with_fx :ixi_techno do
      with_synth :supersaw do
        t = (range 1, 0.05, step: 0.05).reflect
        # When using preparsed ziffers, third parameter can be used as rates, eg. sleep: 0.5 of the original
        zplay(n,{},{sleep: t.tick, amp: (range 1, 0.3, step: 0.1).reflect.tick})
      end
    end
  end
end
