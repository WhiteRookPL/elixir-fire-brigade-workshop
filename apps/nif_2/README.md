# *NIF_2: `SEGAULT` because of faulty NIF (`MagicEightBall`).

**Assignment name**: `NIF_2`

**Topic**: *gdb* / *Core Dump*

## Description

Our "awesome" *NIF* caused whole *VM* to crash. And not even to the `erl_crash.dump`, but to the *core dump*. Are we doomed? Nope, we can debug and solve it!

## How to show it?

Persist command that is longer than 256 characters, and then try to restore it.

```bash
~ $ iex -S mix
```

```elixir
iex(...)1> MagicEightBall.Server.question?("Very long and winded up question, with a lot of words ...")
```

Remember to use a `prod` release, or you will have to change default configuration.

## Detecting root cause

### Setup

```bash
~ $ TMPDIR="~/.asdf/installs/erlang/19.3" ERLANG_EXTRA_CONFIGURE_OPTIONS="--enable-debug" asdf install erlang 19.3

~ $ KERL_CONFIGURE_OPTIONS=--enable-debug kerl build 19.3 19.3_debug
~ $ kerl install 19.3_debug .kerl/installations/19.3_debug
```

### Opening `gdb`

```bash
~ $ gdb ~/.asdf/installs/erlang/19.3/lib/erlang/erts-8.3/bin/beam.smp -core _build/prod/rel/production_debugging_workshop_ex/CORE_DUMP_NAME -d ~/.asdf/installs/erlang/19.3/lib/erlang/otp_src_19.3/erts/emulator
(gdb) source /home/afronski/.asdf/installs/erlang/19.3/otp_src_19.3/erts/etc/unix/etp-commands.in


~ $ gdb ~/.kerl/installations/19.3_debug/erts-8.3/bin/beam.smp -core CORE_DUMP_NAME -d ~/.kerl/builds/19.3_debug/otp_src_19.3/erts/emulator
(gdb) source /home/afronski/.kerl/builds/R16B03-1_debug/otp_src_R16B03-1/erts/etc/unix/etp-commands.in
```

Last command evaluates the `Emulator Toolbox for Pathologists` which allows to show details about the Erlang terms and processes.

## Fix

**Tag**: `FIX_FOR_NIF_2`

```diff
diff --git a/apps/nif_2/c_src/magic_eight_ball_logic.c b/apps/nif_2/c_src/magic_eight_ball_logic.c
index 695e169..c56f043 100644
--- a/apps/nif_2/c_src/magic_eight_ball_logic.c
+++ b/apps/nif_2/c_src/magic_eight_ball_logic.c
@@ -48,6 +48,8 @@ const char* SENTENCES[] = {
   "Very doubtful"
 };
 
+const int SENTENCES_SIZE = sizeof(SENTENCES) / sizeof(char*);
+
 static int load(ErlNifEnv* env, void **priv, ERL_NIF_TERM info)
 {
   srand(time(NULL));
@@ -105,7 +107,7 @@ static ERL_NIF_TERM question(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]
     chunk = strtok(NULL, " ");
   }
 
-  int position = random_from_range(0, words);
+  int position = (random_from_range(0, SENTENCES_SIZE) + words) % SENTENCES_SIZE;
   const char* answer = SENTENCES[position];
 
   return enif_make_tuple2(env, enif_make_atom(env, "ok"), enif_make_string(env, answer, ERL_NIF_LATIN1));
   
```