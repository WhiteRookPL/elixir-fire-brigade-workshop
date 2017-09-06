#!/usr/bin/env bash

echo "Starting 10 nodes with 'TreasureHunt' application..."

N=1

for I in $(seq 10); do
  REPLACE_OS_VARS=true CHEST_KEY="${I}" bash -c "_build/prod/rel/treasure_hunt_node_${N}/bin/treasure_hunt_node_${N} start" >/dev/null 2>&1
  N=$((N+1))
done

echo "Started 10 nodes with 'TreasureHunt' application!"
echo ""
echo "Following nodes are started:"
echo "  - treasure_hunt_node_1"
echo "  - treasure_hunt_node_2"
echo "  - treasure_hunt_node_3"
echo "  - treasure_hunt_node_4"
echo "  - treasure_hunt_node_5"
echo "  - treasure_hunt_node_6"
echo "  - treasure_hunt_node_7"
echo "  - treasure_hunt_node_8"
echo "  - treasure_hunt_node_9"
echo "  - treasure_hunt_node_10"
echo ""
echo "Each one has a following cookie: --cookie 'enter_the_treasure_hunt'"
echo ""
echo "Each node contains application with following function: 'TreasureHunt.open_chest/0'."
echo "Inside one of those 10 applications there is an answer for our riddle."
echo ""
echo "First person that finds it and confirms with trainer will win!"
echo ""
echo "Good Luck! :)"