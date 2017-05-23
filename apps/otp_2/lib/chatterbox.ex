defmodule Chatterboxes do
  use Application

  def start(_type, _args) do
    Chatterboxes.Supervisor.start_link()
  end

  def random_from_range(seed, min, max) do
    {value, new_seed} = :rand.uniform_s(seed)
    {Kernel.trunc(Float.floor(value * (max - min + 1)) + min), new_seed}
  end
end
