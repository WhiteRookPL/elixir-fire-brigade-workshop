# *TOOLS_2*: Reconnaissance in new environment (`SentencesAPI`) 

**Assignment name**: `TOOLS_2`

**Topic**: `:wobserver` and `:observer`

## Description

We have prepared very simple *REST API* based on *Phoenix*, but we're getting wrong answers from it. We need to debug it in order to find a solution.

## How to show it?

You need to enable app:

```bash
~ $ iex -S mix phx.server
```

And invoke following command to get random sentence (you can also point your browser into that *URL* and refresh it couple of times):

```bash
~ $ curl -i http://localhost:4000/api/sentences/random
```

After invoking it couple times you will see that it is not exactly random one.

## Detecting root cause

There are two problems in this example, we are using old *API* and we are using it in wrong way. Where we use `:random` module from *Erlang* it puts seed value in the current process dictionary. If we will invoke `:random.seed` in a different process than a `:random.uniform` it will have the same seed over and over again - which results in the same values in our case.

How we can verify which processes contain the seed values? One way is to use `:observer` or similar tool to do it - before we will fix, we need to confirm that issue (let's find those processes).

Also - if you will look into compiler output, you will find that this *API* is deprecated, let's fix it!

## Fix

**Tag**: `FIX_FOR_TOOLS_2`

```diff
diff --git a/apps/tools_2/lib/sentences_api/application.ex b/apps/tools_2/lib/sentences_api/application.ex
index 2324307..bbe6209 100644
--- a/apps/tools_2/lib/sentences_api/application.ex
+++ b/apps/tools_2/lib/sentences_api/application.ex
@@ -8,8 +8,6 @@ defmodule SentencesAPI.Application do
       supervisor(SentencesAPI.Web.Endpoint, [])
     ]
 
-    :random.seed(:erlang.now)
-
     opts = [ strategy: :one_for_one, name: SentencesAPI.Supervisor ]
     Supervisor.start_link(children, opts)
   end
diff --git a/apps/tools_2/lib/sentences_api/web/helpers.ex b/apps/tools_2/lib/sentences_api/web/helpers.ex
index f8617a3..e881548 100644
--- a/apps/tools_2/lib/sentences_api/web/helpers.ex
+++ b/apps/tools_2/lib/sentences_api/web/helpers.ex
@@ -1,6 +1,8 @@
 defmodule SentencesAPI.Web.Helpers do
   def get_random_from(list) do
-    {:ok, element} = Enum.fetch(list, Kernel.trunc(:random.uniform() * length(list)))
+    :rand.seed(:exs1024, :os.timestamp())
+    {:ok, element} = Enum.fetch(list, Kernel.trunc(:rand.uniform() * length(list)))
+
     element
   end
 end
\ No newline at end of file
```