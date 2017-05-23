# *CRASH_DUMP_1*: Erlang VM crash caused by limit for memory or atom table

**Assignment name**: `CRASH_DUMP_1`

**Topic**: *Erlang Crash Dump*

## Description

There are 2 places in that assignment to fix:

1. We are allocating a lot of memory, due to programmers bug.
2. We are creating atoms based on user input. 
 
Let's look why both cases are a bad idea.

## How to show it?

```bash
~ $ iex -S mix
```

And after a while our *Erlang VM* will be killed and will leave a crash dump. After we will fix this issue and start over again, we will see another crash dump - this time caused by different issue.