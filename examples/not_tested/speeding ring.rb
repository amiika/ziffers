require "~/ziffers/ziffers.rb"

n = zparse("q 3 3 3 4 4 4 2 2 2 6 6 6")

live_loop :test do
  with_fx :echo do
    with_fx :ixi_techno do
      with_synth :supersaw do
        t = (range 1, 0.05, step: 0.05).reflect
        # When using preparsed ziffers, third parameter can be used as rates, eg. duration: 0.5 of the original
        zplay(n,{},{duration: t.tick, amp: (range 1, 0.3, step: 0.1).reflect.tick})
      end
    end
  end
end
