#!/usr/bin/env bash

echo "Stopping 10 nodes with 'TreasureHunt' application..."

for I in $(seq 10); do
  bash -c "_build/prod/rel/treasure_hunt_node_${I}/bin/treasure_hunt_node_${I} stop" >/dev/null 2>&1
done

echo "Stopped 10 nodes with 'TreasureHunt' application."