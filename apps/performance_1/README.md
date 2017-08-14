# *PERFORMANCE_1*: Debugging issues in *GraphQL* endpoints (`LibraryApp`)

**Assignment name**: `PERFORMANCE_1`

**Topic**: `:xprof`

## Description

We have developed a simple *GraphQL API* that is oriented around books and authors. 

For those that are not aware what *GraphQL* is - it is basically a querying language, built in mind with objects graph traversal. It also inverts the responsibility, by allowing clients to define what they need (e.g. only certain fields). Thanks to that and customizable logic when it comes resolving dependencies required by client, we can have flexibility when it comes to *API* interface (which always ends up in some custom defined *REST API* endpoints) and performance better than a typical *REST API*.

*GraphQL* is oriented around couple concepts - for us only two are crucial - queries and mutations. First name is self-explanatory, second is about creates, deletes and updates.

Our application has two entities that can be searched. Book is an entity with following attributes:

- *ID*
- *Title*
- List of *Authors*

Author has following attributes:

- *ID*
- *Name*
- *Surname*
- List of *Books*

We call process of assigning book to an author an *association*. How we perform creating, association and querying? Please read description below, or you can use scripts that are stored inside `graphql` directory in this application.

First we need to prepare our data:

```bash
~    $ cd priv
priv $ ./prepare_data.sh
```

Then we need to start an application:

``` 
~ $ iex -S mix
Erlang/OTP 19 [erts-8.3] [source] [64-bit] [smp:8:8] [async-threads:10] [hipe] [kernel-poll:false]
...
13:57:04.976 [info]  Application is now listening on port 8080.
iex(...)>
```

And now we can interface with *API* in following manner:

```bash
~ $ curl -X POST -d 'mutation createAuthor { createAuthor(name: "Dmitry", surname: "Glukhovsky") { id } }' "http://localhost:8080/api" | jq

{
  "data": {
    "createAuthor": {
      "id": "481"
    }
  }
}

~ $ curl -X POST -d 'mutation createBook { createBook(title: "Metro 2033") { id } }' "http://localhost:8080/api" | jq

{
  "data": {
    "createBook": {
      "id": "3858"
    }
  }
}

~ $ curl -X POST -d 'mutation associateBookWithAuthor { associateBookWithAuthor(title: "Metro 2033", author: "Dmitry Glukhovsky") { id } }' "http://localhost:8080/api" | jq 

{
  "data": {
    "associateBookWithAuthor": {
      "id": "481"
    }
  }
}
```

So far, so good! So what is the problem?

## How to show it?

Our endpoints has really poor performance - let's start the application:

```bash
~ $ iex -S mix
```

And let's query for books by our newly created author - *Dmitry Glukhovsky*:

```bash
~ $ curl -X POST -d '{ booksByAuthor(author: "Dmitry Glukhovsky") { title, id } }' "http://localhost:8080/api" | jq

{
  "data": {
    "booksByAuthor": [
      {
        "title": "Metro 2033",
        "id": "3858"
      }
    ]
  }
}
```

And have a look into our console:

```elixir
13:57:04.976 [info]  Application is now listening on port 8080.
iex(...)>

14:04:43.965 [info]  POST /api

14:04:43.966 [debug] ABSINTHE schema=nil variables=%{}
---
{ booksByAuthor(author: "Dmitry Glukhovsky") { title, id } }
---

14:04:44.210 [info]  Sent 200 in 245ms
```

The same thing will be visible (and you can investigate it in greater details) inside `:xprof` tool:

```elixir
iex(...)> :xprof.start()

# Tool will be available in browser at following URL: `http://localhost:7890`.
```

## Detecting root cause

We have two performance issues in that assignment - both can be easily found with use of `:xprof`.

### No caching

Our data set is a set of files written inside `priv/books` and `priv/authors` directories. It is very static (it changes only when we create new book, author or new association), but we're building maps in memory from it at every single *API* call - in order to solve that problem we will implement very simple *ETS* cache to solve that issue (which will be invalidated when we create new entity).

### Unnecessary calls

Another problem is about some calls that are calling unnecessarily other calls. When we're asking only for a list of books with *Title* and *ID*, we do not need to fetch authors at all - let's implement conditional fetching of those elements, depending on the fact if they were requested or not.

## Fix

**Tag**: `FIX_FOR_PERFORMANCE_1`

```diff
diff --git a/apps/performance_1/lib/library_app/resolver.ex b/apps/performance_1/lib/library_app/resolver.ex
index 80fdc66..0964bcc 100644
--- a/apps/performance_1/lib/library_app/resolver.ex
+++ b/apps/performance_1/lib/library_app/resolver.ex
@@ -11,42 +11,58 @@ defmodule LibraryApp.Resolver do
     {:ok, %{ :id => id, :name => name, :surname => surname }}
   end
 
-  def all_books(_arguments, _info) do
-    authors = get_authors()
-    books = get_books()
-
-    final_books =
-      Enum.map(books, fn(%{ :id => book_id } = map) ->
-        mapped_authors =
-          Enum.filter(authors, fn(%{ :books => books_from_authors }) ->
-            Enum.find(books_from_authors, fn(id) -> book_id == id end) != nil
-          end)
+  def all_books(_arguments, info) do
+    child_fields = Absinthe.Resolution.project(info) |> Enum.map(&(&1.name))
+
+    books = get_books_lazily()
+
+    final_books = case Enum.member?(child_fields, "authors") do
+      true ->
+        authors = get_authors_lazily()
+
+        Enum.map(books, fn(%{ :id => book_id } = map) ->
+          mapped_authors =
+            Enum.filter(authors, fn(%{ :books => books_from_authors }) ->
+              Enum.find(books_from_authors, fn(id) -> book_id == id end) != nil
+            end)
+
+          Map.put(map, :authors, mapped_authors)
+        end)
 
-        Map.put(map, :authors, mapped_authors)
-      end)
+      false ->
+        books
+    end
 
     {:ok, final_books}
   end
 
-  def all_authors(_arguments, _info) do
-    authors = get_authors()
-    books = get_books()
+  def all_authors(_arguments, info) do
+    child_fields = Absinthe.Resolution.project(info) |> Enum.map(&(&1.name))
 
-    final_authors =
-      Enum.map(authors, fn(%{ :books => book_ids } = map) ->
-        mapped_books = Enum.map(book_ids, fn(id) ->
-          Enum.find(books, fn(%{ :id => book_id }) -> book_id == id end)
+    authors = get_authors_lazily()
+
+    final_authors = case Enum.member?(child_fields, "books") do
+      true ->
+        books = get_books_lazily()
+
+        Enum.map(authors, fn(%{ :books => book_ids } = map) ->
+          mapped_books = Enum.map(book_ids, fn(id) ->
+            Enum.find(books, fn(%{ :id => book_id }) -> book_id == id end)
+          end)
+
+          %{ map | books: mapped_books }
         end)
 
-        %{ map | books: mapped_books }
-      end)
+      false ->
+        authors
+    end
 
     {:ok, final_authors}
   end
 
   def books_by_author(%{ :author => author }, _info) do
-    authors = get_authors()
-    books = get_books()
+    authors = get_authors_lazily()
+    books = get_books_lazily()
 
     {author_name, author_surname} = separate_name_and_surname(author)
     author = Enum.find(authors, fn(%{ :name => name, :surname => surname }) -> name == author_name and surname == author_surname end)
@@ -65,8 +81,8 @@ defmodule LibraryApp.Resolver do
   end
 
   def authors_by_title(%{ :title => book_title }, _info) do
-    authors = get_authors()
-    books = get_books()
+    authors = get_authors_lazily()
+    books = get_books_lazily()
 
     book = Enum.find(books, fn(%{ :title => title }) -> book_title == title end)
 
@@ -115,8 +131,8 @@ defmodule LibraryApp.Resolver do
   def associate_book_with_author(_arguments, %{ :author => name_and_surname, :title => book_title }, _info) do
     {author_name, author_surname} = separate_name_and_surname(name_and_surname)
 
-    author = Enum.find(get_authors(),  fn(%{ :name => name, :surname => surname }) -> name == author_name and surname == author_surname end)
-    book = Enum.find(get_books(), fn(%{ :title => title }) -> book_title == title end)
+    author = Enum.find(get_authors_lazily(),  fn(%{ :name => name, :surname => surname }) -> name == author_name and surname == author_surname end)
+    book = Enum.find(get_books_lazily(), fn(%{ :title => title }) -> book_title == title end)
 
     case {author, book} do
       {author, book} when author != nil and book != nil ->
@@ -137,6 +153,26 @@ defmodule LibraryApp.Resolver do
     end
   end
 
+  def get_books_lazily() do
+    case :ets.lookup(LibraryApp.Cache, :books) do
+      [ {_, content} ] -> content
+      []               ->
+        books = get_books()
+        :ets.insert(LibraryApp.Cache, {:books, books})
+        books
+    end
+  end
+
+  def get_authors_lazily() do
+    case :ets.lookup(LibraryApp.Cache, :authors) do
+      [ {_, content} ] -> content
+      []               ->
+        authors = get_authors()
+        :ets.insert(LibraryApp.Cache, {:authors, authors})
+        authors
+    end
+  end
+
   defp get_authors() do
     Path.wildcard(priv("authors/*.author"))
     |> Enum.map(fn(file) -> {String.to_integer(only_number(file, "author")), File.read(file)} end)
diff --git a/apps/performance_1/lib/library_app/supervisor.ex b/apps/performance_1/lib/library_app/supervisor.ex
index 3af8141..fb6909f 100644
--- a/apps/performance_1/lib/library_app/supervisor.ex
+++ b/apps/performance_1/lib/library_app/supervisor.ex
@@ -16,6 +16,13 @@ defmodule LibraryApp.Supervisor do
 
     Logger.info("Application is now listening on port 8080.")
 
+    # Creating our cache. ;)
+    :ets.new(LibraryApp.Cache, [:public, :named_table, :set, {:write_concurrency, true}, {:read_concurrency, true}])
+
+    # Warming up the cache. ;)
+    LibraryApp.Resolver.get_authors_lazily()
+    LibraryApp.Resolver.get_books_lazily()
+
     options = [ strategy: :one_for_one, name: __MODULE__ ]
     supervise(children, options)
   end
```