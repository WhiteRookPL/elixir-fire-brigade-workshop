# *NIF_1: *Hogging Schedulers* because of faulty NIF (`MagicEightBall`).

**Assignment name**: `NIF_1`

**Topic**: *Schedulers* / *System Monitors*

## Description

Okay, we can start and check out either `IEx` session or `prod` release. Why it behaves so sluggish?

## How to show it?

```bash
~ $ MIX_ENV=prod mix release

# Open two `IEx` sessions:
~ $ _build/prod/rel/magic_eight_ball/bin/magic_eight_ball console
~ $ iex --name remsh@127.0.0.1 --remsh magic_eight_ball@127.0.0.1 --cookie "PROD_COOKIE"
```

And then in second one spawn this (you can read about this module below):

```elixir
iex(...)1> TempSysMon.start({:long_schedule, 200})
```

And in first one try to invoke this:

```elixir
iex(...)1> for i <- 0..10_000, do: MagicEightBall.Server.question?("Question number #{i}?")
```

After that will notice the following:

```elixir
iex(...)1> TempSysMon.start({:long_schedule, 200})
#PID<0.1086.0>
monitor=long_schedule pid=#PID<0.870.0> info=[timeout: 124, in: {:gen_server, :loop, 6}, out: {:gen_server, :loop, 6}]
---                               
monitor=long_schedule pid=#PID<0.870.0> info=[timeout: 109, in: {:gen_server, :loop, 6}, out: {:gen_server, :loop, 6}]
---                               
monitor=long_schedule pid=#PID<0.870.0> info=[timeout: 113, in: {:gen_server, :loop, 6}, out: {:gen_server, :loop, 6}]
---                               
monitor=long_schedule pid=#PID<0.870.0> info=[timeout: 142, in: {:gen_server, :loop, 6}, out: {:gen_server, :loop, 6}]
---                               
monitor=long_schedule pid=#PID<0.870.0> info=[timeout: 111, in: {:gen_server, :loop, 6}, out: {:gen_server, :loop, 6}]
```

## Detecting root cause

Okay let's start our application via `prod` release and let's check scheduler utilization:

```elixir
iex(...)1> :recon.scheduler_usage(5000)
iex(...)1> :recon.scheduler_usage(2500)
iex(...)1> :recon.scheduler_usage(1000)
```

Something is definitely wrong (during the execution significantly utilized schedulers are rotating between themselves, mostly 2 of them), you can also see the scheduler utilization graphs in `:observer` - similar observation, they're trying to balance work with each other (which is not a case with high utilization, as one will be utilized all the time).

Thankfully *Erlang VM* has another facility in place for such problems. As an *Erlanger* I really like *Elixir* for many things, but recently started to like more a particular one - you can write complete module in the *REPL*.

```elixir
defmodule TempSysMon do
  defp printer(op) do
    receive do
      {:monitor, pid, type, info} ->
        IO.puts("---")
        IO.puts("monitor=#{type} pid=#{inspect pid} info=#{inspect info}")

        case op do
          nil -> :ok
          _   ->
            result = op.(pid, type, info)
            IO.puts("op=#{inspect result}")
        end
    end
    printer(op)
  end

  def start(monitors, op \\ nil)

  def start(monitor, op) when is_tuple(monitor) do
    start([monitor], op)
  end

  def start(monitors, op) do
    spawn_link(fn () ->
      Process.register(self(), :temp_sys_monitor)
      :erlang.system_monitor(self(), monitors)
      printer(op)
    end)
  end

  def stop() do
    temp_sys_monitor = Process.whereis(:temp_sys_monitor)

    case temp_sys_monitor do
      nil -> :no_temp_sys_monitor
      _   ->
        Process.exit(temp_sys_monitor, :kill)
        :killed
    end
  end
end
```

Evaluate this one and start:

```elixir
iex(...)1> TempSysMon.start({:long_schedule, 200})
#          After a while you can stop.
iex(...)2> TempSysMon.stop()
```

Yup, there is something wrong, you can clearly see it from the `:in` and `:out` - we are getting scheduled out from `{:gen_server, :loop, 6}`. How do we know it is a *NIF*?

Checking provided *PID* shows that it is `MagicEightBall.Server` process, getting scheduled `:in` and `:out` from the same function, and it means that we're waiting there for something (beware of inlining). Call `:gen_server.loop/6` is responsible for `handle_call`, and there we're using only our *NIF*.

And indeed some smart-ass hide there *sleep* commands. ;)

Additionally - this implementation has one more issue - `strtok` and `while` for longer strings may take a lot of time and without yielding or bumping up reductions used by a *NIF* (in other words - time spent there) we will have similar problem, but much more hidden. The rule of thumb is that *NIF* should return immediately (< 1ms, at worst case < 100 ms) otherwise it will be painful for scheduling and reductions.

And last, but not least - `strtok` is not thread safe and it is not re-entrant - it means that it modifies the global state where it stores the tokenization state. In our case it would be hard to show as individual *NIF* calls are atomic and we're finishing tokenization in one *NIF* call. But proper version should use at least `strtok_r`, but *TBH* - it should use totally different implementation for tokenization.

## Fix

**Tag**: `FIX_FOR_NIF_1`

```diff
diff --git a/apps/nif_1/c_src/magic_eight_ball_logic.c b/apps/nif_1/c_src/magic_eight_ball_logic.c
index 997f2a3..09874a5 100644
--- a/apps/nif_1/c_src/magic_eight_ball_logic.c
+++ b/apps/nif_1/c_src/magic_eight_ball_logic.c
@@ -20,19 +20,11 @@ USE OR OTHER DEALINGS IN THE SOFTWARE. HERE BE DRAGONS. AND SEGFAULTS. I AM WOND
 IF SOMEONE ACTUALLY READING HEADERS. THIS IS NOT A DRILL. ALL YOUR BASE ARE BELONG TO US.
 */
 
-#ifdef _WIN32
-  #include <windows.h>
-#else
-  #include <unistd.h>
-#endif
-
 #include <time.h>
 #include <stdio.h>
 #include <string.h>
 #include <erl_nif.h>
 
-#define ASSERT(exp) (reassert(exp))
-
 const char* SENTENCES[] = {
   "It is certain",
   "It is decidedly so",
@@ -58,19 +50,6 @@ const char* SENTENCES[] = {
 
 const int SENTENCES_SIZE = sizeof(SENTENCES) / sizeof(char*);
 
-static void reassert(int result) {
-  double random = (double) rand() / (double) RAND_MAX;
-  unsigned int t = (unsigned int)(((double) rand() / (double) RAND_MAX) * 1000.0);
-
-  if (random >= 0.95 && result == 1) {
-    #ifdef _WIN32
-    Sleep(t);
-    #else
-    usleep(t * 1000);
-    #endif
-  }
-}
-
 static int load(ErlNifEnv* env, void **priv, ERL_NIF_TERM info)
 {
   srand(time(NULL));
@@ -126,7 +105,6 @@ static ERL_NIF_TERM question(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]
   while(chunk != NULL) {
     ++words;
     chunk = strtok(NULL, " ");
-    ASSERT(chunk != NULL);
   }
 
   int position = random_from_range(0, 19);

```