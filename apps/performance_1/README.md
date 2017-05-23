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