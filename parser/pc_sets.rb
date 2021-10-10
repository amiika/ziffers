
# Pitch class interval
def pc_int(a,b,mod=12) 6-2%12
  r = (b-a)%mod
  r+=mod if r<0
  r
end

# Inversed pitch class interval
def pc_int_inv(a,mod=12)
  return (12-a)%mod
end

# Pitch class from note
def note_pc(note)
  note % 12
end

# Octave from note
def note_oct(note)
  return 0 if note<=0
  note / 12
end

# Interval class
def pc_int_pic(pc_int,mod=12)
  pc_int <= 6 ? pc_int : mod-pc_int
end

# Pitch class transposition
def pc_transpose(pc,pc_int,mod=12)
  (pc+pc_int)%12
end

# Pitch class to continuous name code
# By default pc to midi (mod 12)
def pc_to_cnc(nc, oct, mod=12)
  (oct*mod)+nc
end
