defmodule RandomServer.Randomizer.Test do
  use ExUnit.Case, async: false

  test "that random server should return uniform random number" do
    min = 0.0
    max = 1.0

    assert {:result, value} = RandomServer.Randomizer.rand()
    assert value >= min
    assert value <  max
  end

  test "that random sequential calls should return random number" do
    assert RandomServer.Randomizer.rand() != RandomServer.Randomizer.rand()
  end

  test "that random server should return random number from range" do
    min = 5
    max = 10

    assert {:result, value} = RandomServer.Randomizer.range(min, max)
    assert value >= min
    assert value <= max
  end

  test "that you should be able to change algorithm in random server" do
    assert {:changed, _} = RandomServer.Randomizer.change_algorithm(:exs1024)
  end

  test "that you should be able to shuffle a list in random server" do
    original = [ 1, 2, 3, 4, 5 ]

    assert {:result, shuffled} = RandomServer.Randomizer.randomize_list(original)
    assert shuffled != original
  end

  test "that you should be able to commands history in random server" do
    assert {:history, commands} = RandomServer.Randomizer.history()

    assert length(commands) == 6
  end
end