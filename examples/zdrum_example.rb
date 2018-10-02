
live_loop :melody do
  with_synth :fm do
    zplay("|:q111 e35q222e46:|q64534231|e2343 4564 5676 7567",{amp: 0.7})
  end
end

live_loop :mdd do
  zdrums "|:q111 e35q222e46:3|e5555 4444 3333 4321", amp: 0.5, synth: :sine
end
