defmodule Crasher do
  use Application

  def start(_type, _args) do
    Crasher.Supervisor.start_link()
  end

  def random_from_range(min, max) when max > min do
    <<i1 :: 32, i2 :: 32, i3 :: 32>> = :crypto.strong_rand_bytes(12)

    seed = :rand.seed_s(:exs1024, {i1, i2, i3})
    {value, _} = :rand.uniform_s(seed)

    Kernel.trunc(Float.floor(value * (max - min + 1)) + min)
  end
end
