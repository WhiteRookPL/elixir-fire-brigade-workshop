defmodule TreasureHuntTest do
  use ExUnit.Case

  test "main application should boot up" do
    assert {:ok, _} = TreasureHunt.start(:normal, [])
  end
end