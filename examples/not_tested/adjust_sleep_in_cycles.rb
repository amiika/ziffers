load "~/ziffers/ziffers.rb"

z1 "|:q0 1 2 0:|Q: q 2 3 h4:|W: e4 5 4 3 q2 0:|: q0 _4 ^h0:|"

# Adjust parameters: 1st ziff object, 2nd ziff index, 3rd loop cycle number
# Note: index (i) and cycle number (n) starts from 0
z2 "|:q0 1 2 0:|Q: q 2 3 h4:|W: e4 5 4 3 q2 0:|: q0 _4 ^h0:|", adjust: ->(z,i,n){ z[:sleep]*=n%4+1 }
