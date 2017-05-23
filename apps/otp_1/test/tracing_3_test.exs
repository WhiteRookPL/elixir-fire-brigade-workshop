defmodule BrokenSupervisionTreeTest do
  use ExUnit.Case

  test "main application should boot up" do
    assert {:ok, _} = BrokenSupervisionTree.start(:normal, [])
  end
end