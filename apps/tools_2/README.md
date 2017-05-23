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