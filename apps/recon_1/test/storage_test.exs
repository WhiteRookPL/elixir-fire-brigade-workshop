defmodule RedisClone.Storage.Test do
  use ExUnit.Case, async: true

  setup_all do
    %{ :table => RedisClone.Storage.initialize(:test_bucket) }
  end

  test "when there are no keys you should get nothing", context do
    assert :nothing == RedisClone.Storage.get(context[:table], "unknown_key")
  end

  test "storage should be able to get and retrieve key and value", context do
    RedisClone.Storage.put(context[:table], "shopping", "milk")

    assert "milk" == RedisClone.Storage.get(context[:table], "shopping")
  end

  test "after deleting pair from storage you should get nothing", context do
    RedisClone.Storage.put(context[:table], "magic_trick", "puff!")
    RedisClone.Storage.delete(context[:table], "magic_trick")

    assert :nothing == RedisClone.Storage.get(context[:table], "magic_trick")
  end

  test "listing keys should list all of them", context do
    RedisClone.Storage.put(context[:table], "listed_key", "aha!")

    assert true == String.contains?(RedisClone.Storage.keys(context[:table]), "listed_key")
  end
end