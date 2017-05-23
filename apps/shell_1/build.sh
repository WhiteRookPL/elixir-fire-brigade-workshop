#!/usr/bin/env bash

echo "Building releases for 10 nodes with 'TreasureHunt' application..."

for I in $(seq 10); do
  MIX_ENV=prod mix release --name "treasure_hunt_node_${I}" >/dev/null 2>&1
done

echo "Built 10 releases with 'TreasureHunt' application!"