defmodule CrashDumpTest do
  use ExUnit.Case

  test "main application should boot up" do
    assert {:ok, _} = CrashDump.start(:normal, [])
  end
end