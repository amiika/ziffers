require "~/ziffers/ziffers.rb"

live_loop :spread do
  (spread 7, 32).each do |bool|
    zplay bool ?  "[h? ?,q3 1 ? ?,e? ? ? ? ? ? ? ?]" : "q1 3 ? ?"
  end
end
