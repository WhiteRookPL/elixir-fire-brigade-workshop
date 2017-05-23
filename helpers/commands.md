# Commands and Helpers

**CAUTION** - in examples by tilde (`~`) we mean a directory with particular assignment from your cloned repository.

## Development mode

```bash
~ $ iex -S mix
~ $ iex -S mix phx.server
~ $ iex --name "server@127.0.0.1" --cookie "SOME COOKIE" -S mix phx.server
```

## Invoking tests

```bash
~ $ mix test
~ $ mix test --seed 971306
~ $ mix test test/kv_registry_test.exs:41
```

## Getting familiar with the application

```bash
~ $ mix deps.tree
~ $ mix app.tree --exclude elixir --exclude logger
```

## Listing available routes in *Phoenix* application

```bash
~ $ mix phx.routes SpellCheckerAPI.Web.Router

checker_path  GET  /api/spell-check/:word   SpellCheckerAPI.Web.CheckerController :spell_check
dictionary_path  GET  /api/dictionary/:letter  SpellCheckerAPI.Web.DictionaryController :words_for_letter
```

### Drawing application dependency graph

```bash
~ $ mix app.tree --exclude logger --exclude elixir --exclude crypto --format dot
~ $ dot -Tpng apps/kv_rest_api/app_tree.dot -o app_tree.png
```

## Building release

```bash
~ $ MIX_ENV=prod mix release
```

How to start release? Watch the guides after successful release build process.

### Starting release with a console

```bash
~ $ _build/prod/rel/treasure_hunt_node_1/bin/treasure_hunt_node_1 console
```

### Starting and stopping release in the background

```bash
~ $ _build/prod/rel/treasure_hunt_node_1/bin/treasure_hunt_node_1 start
~ $ _build/prod/rel/treasure_hunt_node_1/bin/treasure_hunt_node_1 stop
```

### Attaching to the running node started in backround as a release

```bash
~ $ _build/prod/rel/treasure_hunt_node_1/bin/treasure_hunt_node_1 attach
```

## Second node with `:observer`

```bash
~ $ iex --name "observer@127.0.0.1" --cookie "SOME COOKIE"
iex(...)> Node.connect(:'server@127.0.0.1')
iex(...)> Node.list()
iex(...)> :observer.start()
```

## Remote shell to the existing node

```bash
~ $ iex --name "remsh_node@127.0.0.1" --cookie "SOME COOKIE" --remsh "running_node_with_server@127.0.0.1"
```

## `:etop`

```elixir
iex(...)> :etop.start()
# Available columns for sorting: `msg_q`, `reductions`, `memory`, `runtime`:
iex(...)> :etop.start(interval: 1, sort: :reductions)
iex(...)> :etop.stop()
```

## `:xprof`

### Starting application

```elixir
iex(...)> :xprof.start()
```

And then go to the `http://localhost:7890` (we recommend using an *incognito tab* to avoid issues with browser extensions). It will detect automatically if you are using *Elixir* or *Erlang* project and adjust syntax to it accordingly.

Do not forget to add it into your release, if you want to have available it in production.

## `:eper`

### Facilities different than `:redbug`

- `eper` is a loose collection of Erlang Performance related tools.
  - We talked a lot about `redbug` already which is a part of that toolkit.
  - But there are other interesting tools:
    - `dtop` - Similar to UNIX `top`.
      - `:dtop.start()`
    - `ntop` - Visualizes network traffic.
      - `:ntop.start()` - and it shows ports, then you can work with e.g. `recon`.
    - `atop` - Shows various aspects of the VM allocators.
      - `:atop.help()` - and then go along the guides.

### `:redbug`

```elixir
iex(...)> :redbug.start(~C['Elixir.KV.Bucket':keys->return], print_msec: true)
iex(...)> :redbug.start(~C['Elixir.Plug.Conn':read_body->return], time: 1_000, msgs: 2)
iex(...)> :redbug.start(1000, 2, ~C['Elixir.Plug.Conn':read_body->return])
iex(...)> :redbug.start(~C[erlang:binary_to_atom->stack])
```

## `:dbg`

```elixir
iex(...)> :dbg.tracer()
iex(...)> :dbg.p(:all, :c)                      # Trace calls in all processes.
iex(...)> :dbg.p(:new, :p)                      # Trace process events only in newly spawned processes.
iex(...)> :dbg.p(:all, :m)                      # Trace all messages (incoming / outgoing) in all processes.
iex(...)> :dbg.tp(:'Elixir.Enum', :into, :x)    # Trace pattern for all arities of `Enum.into` that will show *exception trace* (function, arguments, return value and exceptions for a function).
iex(...)> :dbg.tp(:'Elixir.Enum', :into, :c)    # Trace pattern for all arities of `Enum.into` that will show *caller trace* (as above but about function that called it).
iex(...)> :dbg.tp(:'Elixir.Enum', :into, :cx)   # Trace pattern for all arities of `Enum.into` that will show data from both type of *traces*.
iex(...)> :dbg.stop()                           # Stops tracer.
iex(...)> :dbg.stop_clear()                     # Stops tracer and clears trace patterns.
```

## `:recon`

### Crash Dump Analysis

```bash
~ $ ./deps/recon/scripts/erl_crashdump_analyzer.sh erl_crash.dump
~ $ awk -v threshold=10000 -f ./deps/recon/scripts/queue_fun.awk erl_crash.dump
```

You can also open and analyse an *crash dump* with classic `:observer` application.

### Observability

- `:recon.scheduler_usage(1000)`
    - Polls schedulers for 1s and shows utilization in percentages.
- `:recon.port_types()`
    - Lists a summary which ports are opened in the system.
- `:recon.info(self(), work)`
    - Showing info about particular process depending on available groups (also `recon` gathers and returns only those safe metrics).
- `:recon.proc_count(memory, 3)`
    - Top 3 processes when it comes to memory.
- `:recon.bin_leak(5)`
    - Take 5 processes which released the most amount of memory after forced GC in comparison to before.
        - It is related with the mechanism of *reference counted* binaries, *Erlang* will not release those without forcing it.

### `:recon_trace`

```elixir
# We want at most 2 messages matching `erlang.binary_to_integer/1`:
iex(...)> :recon_trace.calls({:erlang, :binary_to_integer, 1}, 2)
# At most 3 messages and we are interested in stack trace:
iex(...)> :recon_trace.calls({:queue, :in, fn(_) -> :return_trace end}, 3)
# We are interested in any arity of `:queue.new` function:
iex(...)> :recon_trace.calls({:queue, :new, :_}, 1)
# Stop tracing if you will get more than 10 messages in 1s:
iex(...)> :recon_trace.calls({KV.Registry, :handle_call, 3}, {10, 1000})
# Clear and reset tracer:
iex(...)> :recon_trace.clear()
```

## Encrypt / decrypt answer for a `SHELL_1` assignment

```bash
# Encryption:
~ $ echo "Secret" | openssl rsautl -inkey RSA_KEY_USED_FOR_ENCRYPTION -encrypt | base64

# Decryption:
~ $ echo "asdf213==" | base64 --decode | openssl rsautl -inkey RSA_KEY_USED_FOR_ENCRYPTION -decrypt
```

## Preparing `pl.dict` file for *PERFORMANCE_2* task

```bash
~ $ aspell -d pl dump master | aspell -l pl expand > pl.dict
```

## `:sys`

### `:sys.trace`

```elixir
iex(...)> :sys.trace(Process.whereis(KV.Registry), true)
iex(...)> :sys.trace(pid, true)
```

### Other facilities from `:sys:

- `:sys.get_state(pid_or_name)`
- `:sys.get_status(pid_or_name)`
- `:sys.get_status(pid_or_name, [ false | true | :get ])` - when flag is `:get` it will return the following statistics:
    - `{:start_time, date_time1}`
    - `{:current_time, date_time2}`
    - `{:reductions, integer() >= 0}`
    - `{:messages_in, integer() >= 0}`
    - `{:messages_out, integer() >= 0}`
- `:sys.replace_state(pid_or_name, fn(state) -> ... new_state end)`

## System Monitors

- Amazing facility for tracking down various strange situation with probes
  available on virtual machine, e.g. long schedule pauses, busy ports or long GC operations.
  ```elixir
  iex(...)> :erlang.system_monitor()
  iex(...)> :erlang.system_monitor(self(), [ {:long_gc, 500} ])
  iex(...)> flush()
      Shell got {monitor,<4683.31798.0>,long_gc,
                 [{timeout,515},
                  {old_heap_block_size,0},
                  {heap_block_size,75113},
                  {mbuf_size,0},
                  {stack_size,19},
                  {old_heap_size,0},
                  {heap_size,33878}]}
  iex(...)> :erlang.system_monitor(:undefined)
  {<0.26706.4961>,[{long_gc,500}]
  iex(...)> :erlang.system_monitor()
  undefined
  ```
  - Other options:
    - `{large_heap, NumWords}`
    - `{long_schedule, Ms}`.
  - Being able to create whole module in _REPL_ is the best possible thing.
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

## Core Dumps

### Enabling / disabling core dumps

```bash
# Enable core dumps:
~ $ ulimit -c unlimited

# Create them in current directory, with specified file name:
~ $ sudo bash -c "echo "core.%e.%p" > /proc/sys/kernel/core_pattern"

# Disable core dumps:
~ $ ulimit -c 0
```

### Compiling *Erlang VM* with debug symbols

```bash
# Using `asdf` version manager:
~ $ TMPDIR="~/.asdf/installs/erlang/19.3" ERLANG_EXTRA_CONFIGURE_OPTIONS="--enable-debug" asdf install erlang 19.3

# Using `kerl`: 
~ $ KERL_CONFIGURE_OPTIONS=--enable-debug kerl build 19.3 19.3_debug
~ $ kerl install 19.3_debug .kerl/installations/19.3_debug
```

### Opening `gdb`

```bash
# When using `asdf`:
~ $ gdb ~/.asdf/installs/erlang/19.3/lib/erlang/erts-8.3/bin/beam.smp -core _build/prod/rel/production_debugging_workshop_ex/CORE_DUMP_NAME -d ~/.asdf/installs/erlang/19.3/lib/erlang/otp_src_19.3/erts/emulator
(gdb) source /home/afronski/.asdf/installs/erlang/19.3/otp_src_19.3/erts/etc/unix/etp-commands.in

# When using `kerl`:
~ $ gdb ~/.kerl/installations/19.3_debug/erts-8.3/bin/beam.smp -core CORE_DUMP_NAME -d ~/.kerl/builds/19.3_debug/otp_src_19.3/erts/emulator
(gdb) source /home/afronski/.kerl/builds/R16B03-1_debug/otp_src_R16B03-1/erts/etc/unix/etp-commands.in
```

### `gdb` Cheatsheet

- `bt` - Get stack trace from current thread.
- `frame N` - Move to `N` frame.
- `i thr` - List all threads.
- `thr N` - Move to `N` thread.
- `print VAR` - Print variable `VAR`.
- `print p->off_heap` - Print off-heap pointer for *Erlang* *Process* pointer `p`.
- `etp-offheapdump PTR` - Memory dump regarding off-heap data for that *Process* `PTR`.
- `etp-process-info p` - If you have *Erlang VM* *Process* pointer called `p` you can get details from it.
- `etp VAR` or `etpf VAR` - Printing *Erlang* terms stored in `VAR`.
- `etp-stacktrace p` - Print *Erlang* stack-trace from `p`.
- `etp-stackdump p` - Print *Erlang* stack and memory for process `p`.
- `etp-help` - For more help than usual.

## External tracing for *BEAM* with *lttng*

### Installing *lttng*

You can find an extensive description [here](http://lttng.org/download).

In our example we will show how to install it on *Arch Linux*:

```bash
# Update whole system:
~ $ sudo pacman -Syu

# And perform a reboot, if kernel was updated in that round.

# Then you can you can use any AUR client to fetch those 5 packages:
~ $ pacaur -S lttng-tools lttng-ust lttng-modules-git babeltrace liburcu

# You need `lttng-modules-git` if you have kernel 4.12.5 or above.
```

### Compiling *Erlang VM* with *lttng* support

```bash
# Version `19.3` is the most recent one used by me somewhere else,
# and `asdf` does not let me install it under different name.
# So I am using `19.2`.

~ $ TMPDIR="/home/afronski/.asdf/installs/erlang/19.2/"         \
    ERLANG_CONFIGURE_OPTIONS="                                  \
      --enable-debug                                            \
      --disable-hipe                                            \
      --with-dynamic-trace=lttng                                \
      --with-ssl=/dest/dir/for/libressl/make/install/usr/local  \
    asdf install erlang 19.2
```

**CAUTION**: Those configuration options are **not suitable** for production use. They are only for demoing purpose and they are specific to the incompatibilities with *OpenSSL 1.1.x* and newest `gcc` tool-chain on *ArchLinux*.