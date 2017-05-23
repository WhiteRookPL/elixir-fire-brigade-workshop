defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    {:ok, _} = KV.Registry.start_link(context.test)
    {:ok, registry: context.test}
  end

  test "spawns buckets", %{registry: registry} do
    assert KV.Registry.lookup(registry, "shopping") == :error

    KV.Registry.create(registry, "shopping")
    assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    KV.Bucket.put(bucket, "milk", 1)
    assert KV.Bucket.get(bucket, "milk") == 1
  end

  test "removes buckets on exit", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
    Agent.stop(bucket)

    # Do a sync to ensure the registry processed the down message
    _ = KV.Registry.create(registry, "bogus")
    assert KV.Registry.lookup(registry, "shopping") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    # Stop the bucket with non-normal reason
    Agent.stop(bucket, :shutdown)

    # Do a sync to ensure the registry processed the down message
    _ = KV.Registry.create(registry, "bogus")
    assert KV.Registry.lookup(registry, "shopping") == :error
  end

  test "deletes existing bucket", %{registry: registry} do
    KV.Registry.create(registry, "shopping")

    assert KV.Registry.delete(registry, "shopping") == :bucket_deleted
    assert KV.Registry.lookup(registry, "shopping") == :error
  end

  test "complains when delete non-existing bucket", %{registry: registry} do
    assert KV.Registry.delete(registry, "shopping") == :no_such_bucket
  end

  test "lists all buckets", %{registry: registry} do
    KV.Registry.create(registry, "foo")
    KV.Registry.create(registry, "bar")
    KV.Registry.create(registry, "baz")
    KV.Registry.create(registry, "qux")
    KV.Registry.delete(registry, "bar")

    assert KV.Registry.buckets(registry) == [ "baz", "foo", "qux" ]
  end
end
