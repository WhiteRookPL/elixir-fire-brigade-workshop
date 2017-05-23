# *SHELL_1*: Playing with BEAM shell sessions! (`TreasureHunt`)

**Assignment name**: `SHELL_1`

**Topic**: *Shell* and related topics

## Description

This assignment is a small riddle / competition who will find an answer hidden inside one of multiple nodes connected via *distributed Erlang*. Any approach you will take is valid, assuming that you're using shell sessions or any other way of attaching to the *Erlang node*.

**CAUTION**: *Windows* people - please use *Linux subsystem* or *Cygwin* for that assignment.
**CAUTION**: *macOS* / *OSX* people - please install `coreutils` first (e.g. via `brew`).

## How to show it?

This task requires preparation - we need to build 10 releases for our riddle.

```bash
~ $ ./build.sh
```

Then everyone should simultaneously start nodes via this script:

```bash
~ $ ./start.sh

Starting 10 nodes with 'TreasureHunt' application...
Started 10 nodes with 'TreasureHunt' application!

Following nodes are started:
  - treasure_hunt_node_1
  - treasure_hunt_node_2
  - treasure_hunt_node_3
  - treasure_hunt_node_4
  - treasure_hunt_node_5
  - treasure_hunt_node_6
  - treasure_hunt_node_7
  - treasure_hunt_node_8
  - treasure_hunt_node_9
  - treasure_hunt_node_10

Each one has a following cookie: --cookie 'enter_the_treasure_hunt'

Each node contains application with following function: 'TreasureHunt.open_chest/0'.
Inside one of those 10 applications there is an answer for our riddle.

First person that finds it and confirms with trainer will win!

Good Luck! :)
```

After invoking aforementioned function, on any node you will get either *base64* encoded string (which is our answer) or something else will happen :wink:. 

Remember that just 1 from those 10 calls contain a valid answer for our riddle If you will get it, please call the trainer for a validation. First person that will find it, will win!

That script will print out clues and guides how to tackle that assignment. If you would like to start from scratch, you need to stop all nodes and start them again (but it will have different order after such operation)

```bash
~ $ ./stop.sh
```

## Solution

The quickest possible solution it to use `:rpc.multicall/5`:

```bash
~ $ iex --name 'test@127.0.0.1' --cookie 'enter_the_tresure_hunt'
```

```elixir
iex(...)> Node.list()
[]
iex(...)> Node.connect(:'treasure_hunt_node_1@127.0.0.1')
true
iex(...)> Node.list()
[ ... list of 10 nodes ... ]
iex(...)> :rpc.multicall(Node.list(), TreasureHunt, :open_chest, [], 2000)
[ ... list of answers from 10 nodes, including two encrypted solutions ... ]
```

However there are two pitfalls here - first one is related to the `timeout`, which by default for a `:rpc.multicall/4` is equal to `:infinity`, and one implementation inside those nodes hangs and stops everyone else. 

Second pitfall is different, because after that call, your started node will be also closed - it means that one of implementations broadcast the `:init.stop/0` call to all connected nodes.

We can fix latter by slightly changed approach to the problem:

```bash
~ $ iex --name 'test@127.0.0.1' --cookie 'enter_the_tresure_hunt' --hidden
```

Hidden node won't be closed, but we will not have full list of nodes too available via `Node.list/0`, so we need to do it one by one:

```elixir
iex(...)> :rpc.call(:'treasure_hunt_node_1@127.0.0.1', TreasureHunt, :open_chest, [], 2000)
...
iex(...)> :rpc.call(:'treasure_hunt_node_2@127.0.0.1', TreasureHunt, :open_chest, [], 2000)
...
iex(...)> :rpc.call(:'treasure_hunt_node_3@127.0.0.1', TreasureHunt, :open_chest, [], 2000)
...
```

As we're now hidden and not connected to the cluster, that vicious node will not be able to kill us, still - if we will hit it earlier than we will find our answer, we need to start again. :confused:

## Fix

There is no fix needed for that assignment - it is about fun, speed and various ways to play with *shell sessions* and *distributed Erlang*.