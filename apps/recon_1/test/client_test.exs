defmodule RedisClone.Client.Test do
  use ExUnit.Case, async: true

  test "happy path for a RedisClone client" do
    assert ":NOT FOUND:" == RedisClone.Client.command("GET todo")

    assert "OK" == RedisClone.Client.command("PUT todo payments")
    assert "payments" == RedisClone.Client.command("GET todo")

    assert "OK" == RedisClone.Client.command("PUT todo2 payments")
    assert "todo2,todo" == RedisClone.Client.command("KEYS")

    assert "OK" == RedisClone.Client.command("DELETE todo")
    assert ":NOT FOUND:" == RedisClone.Client.command("GET todo")

    assert ":UNKNOWN COMMAND:" == RedisClone.Client.command("FOO")
  end
end