# *PERFORMANCE_3*: Debugging slow SQL queries (`MetricsCollector`)

**Assignment name**: `PERFORMANCE_3`

**Topic**: `:xprof`

## Description

We have prepared simple application that allows collecting metrics related to user tracking (*user agents* and data collected from browsers and sent to *API* as a *JSON* document).

However there are some performance problems, when it comes to aggregates and other read-only endpoints.

### Prerequisites

This assignment requires *PostgreSQL* database running on your host, the easiest way to create such is to use *Docker*. Also we need data in that database, but that piece can be generated with *seed* script:

```bash
~ $ docker run --name postgresql -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres
~ $ mix ecto.setup
# That command may take ~10 minutes as we're seeding the database.
```

## How to show it?

We have couple of issues with this *API*, let's start our application:

```bash
~ $ iex -S mix phx.server
```

And let's start `:xprof` that will help us investigating performance issues:

```elixir
iex(...)> :xprof.start()
```

### Too many pages after seeding

```bash
~ $ curl -s "http://localhost:4000/api/pages" | jq
```

### Fetching too many records unnecessarily

```bash
~ $ curl -s "http://localhost:4000/api/pages" | jq
```

### Too many records without limit

```bash
~ $ curl -s "http://localhost:4000/api/tracking" | jq
```