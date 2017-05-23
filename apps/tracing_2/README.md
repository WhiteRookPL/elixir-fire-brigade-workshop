# *TRACING_2*: Debugging failing test with tracing (`KV.RegistryTest`).

**Assignment name**: `TRACING_2`

**Topic**: `:sys` + *Tracing*

## Description

Probably you couldn't see that immediately, but there is one test failing in non deterministic way. Let's tackle this problem!

## How to show it?

1. Test isolation will not work, at least not in ideal way - test still fails in non deterministic way.
2. For me it failed with following `seed` - still in non-deterministic way:
   ```bash
   ~ $ cd apps/tracing_2
   ~ $ mix test test/kv_registry_test.exs:41 --seed 971306
   ```
3. The way to finally force it:
   ```bash
   ~ $ cd apps/tracing_2
   ~ $ while true; do mix test test/kv_registry_test.exs:41 --seed 971306; if [[ $? -ne 0 ]]; then break; fi; done
   ```