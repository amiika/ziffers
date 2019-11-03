load "~/ziffers/ziffers.rb"

z1 "q 1 2 3 4 A 4 5", seed: 1, A: ->() { foo }

def foo
  zplay "123"
end





