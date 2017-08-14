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

## Detecting root cause

### Too many pages after seeding

**Whoops!** How come we have more than 100 pages? It turns out that we have bug in our `seed.exs` script. Let's fix it and reseed the database.

### Fetching too many records unnecessarily

Huh, this *API* call is still slow. Why? It turns out that we are loading unnecessarily an association. After removing it works much better!

### Too many records without limit

Huh, we're downloading *100 000* points from *PostgreSQL* database - it takes a lot of time and doesn't make sense, we should add an limit there. After adding it *API* call works much better.

## Fix

**Tag**: `FIX_FOR_PERFORMANCE_3`

```diff
diff --git a/apps/performance_3/lib/metrics_collector/web/controllers/page_controller.ex b/apps/performance_3/lib/metrics_collector/web/controllers/page_controller.ex
index 453bdc8..fcf32fb 100644
--- a/apps/performance_3/lib/metrics_collector/web/controllers/page_controller.ex
+++ b/apps/performance_3/lib/metrics_collector/web/controllers/page_controller.ex
@@ -6,7 +6,7 @@ defmodule MetricsCollector.Web.PageController do
   alias MetricsCollector.Schema.Organization
 
   def list_all(conn, _params) do
-    pages = Repo.all(Page) |> Repo.preload(:tracking_points)
+    pages = Repo.all(Page)
     render conn, "list.json", pages: pages
   end
 
diff --git a/apps/performance_3/lib/metrics_collector/web/controllers/tracking_point_controller.ex b/apps/performance_3/lib/metrics_collector/web/controllers/tracking_point_controller.ex
index af0b3d6..c2d121c 100644
--- a/apps/performance_3/lib/metrics_collector/web/controllers/tracking_point_controller.ex
+++ b/apps/performance_3/lib/metrics_collector/web/controllers/tracking_point_controller.ex
@@ -1,12 +1,20 @@
 defmodule MetricsCollector.Web.TrackingPointController do
   use MetricsCollector.Web, :controller
 
+  import Ecto.Query, only: [ from: 2 ]
+
   alias MetricsCollector.Schema.Repo
   alias MetricsCollector.Schema.TrackingPoint
   alias MetricsCollector.Schema.Page
 
-  def list_all(conn, _params) do
-    tracking_points = Repo.all(TrackingPoint)
+  def list_all(conn, %{ "limit" => limit }) do
+    maximum = min(limit, 1000)
+    query =
+      from p in "tracking_points",
+      limit: ^maximum,
+      select: {p.id, p.user_agent, p.content, p.page_id, p.inserted_at, p.updated_at}
+
+    tracking_points = Repo.all(query)
     render conn, "list.json", tracking_points: tracking_points
   end
 
@@ -30,4 +38,4 @@ defmodule MetricsCollector.Web.TrackingPointController do
     tracking_point = Repo.insert!(%TrackingPoint{ page: page, content: content, user_agent: user_agent })
     render conn, "single.json", tracking_point: tracking_point
   end
-end
+end
\ No newline at end of file
diff --git a/apps/performance_3/lib/metrics_collector/web/router.ex b/apps/performance_3/lib/metrics_collector/web/router.ex
index fd6d152..29d75df 100644
--- a/apps/performance_3/lib/metrics_collector/web/router.ex
+++ b/apps/performance_3/lib/metrics_collector/web/router.ex
@@ -16,7 +16,7 @@ defmodule MetricsCollector.Web.Router do
     get "/page/:id", PageController, :get_by_id
     put "/pages", PageController, :create
 
-    get "/tracking", TrackingPointController, :list_all
+    get "/tracking/:limit", TrackingPointController, :list_all
     get "/tracking/point/:id", TrackingPointController, :get_by_id
     get "/tracking/for_page/:page_id", TrackingPointController, :get_by_page_id
     put "/track", TrackingPointController, :create
diff --git a/apps/performance_3/priv/repo/seeds.exs b/apps/performance_3/priv/repo/seeds.exs
index 400e421..80ca728 100644
--- a/apps/performance_3/priv/repo/seeds.exs
+++ b/apps/performance_3/priv/repo/seeds.exs
@@ -18,7 +18,7 @@ defmodule Seed do
     appliscale = Repo.insert!(Organization.changeset(%Organization{}, %{ name: "Appliscale" }))
 
     pages = for i <- 1 .. 100, into: [] do
-      page_within_organization("https://appliscale.io/page_#{i}", appliscale)
+      Repo.insert!(page_within_organization("https://appliscale.io/page_#{i}", appliscale))
     end
 
     for _ <- 1 .. 100_000 do
```