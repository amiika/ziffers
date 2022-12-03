load "~/ziffers/ziffers.rb"

define :foo do
  zplay "s123"
end

define :bar do |v=nil|
  zplay v ? v.to_s : "s531"
end

zplay "q F B F e B B B", F: :foo, B: :bar

zplay "e:foo:bar(342) n:bar(012) :bar(438)"
