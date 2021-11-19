load "~/ziffers/ziffers.rb"

define :foo do
  zplay "s123"
end

define :bar do
  zplay "s531"
end

z1 "q F B F e B B B", F: :foo, B: :bar
