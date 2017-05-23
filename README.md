# Debugging Elixir in Production - *Workshop*

## **Join the Elixir Fire Brigade - Level-up Your Elixir Debugging Skills**

Both *Erlang* and *Elixir* are praised for their "debuggability". It's true - there's a lot of tools and techniques that can be used, even on live, production systems. Not only that - they are easily accessible and freely usable. Together we're going to explore them in depth.

We're going to learn what exactly happens when you call a GenServer, how to "spy" on processes and introspection the *VM* internals. We're going to work with an example application - a basic key-value store built on top of plug, prepare a release for it and deploy it to production. Unfortunately, after the deployment we're going to discover some errors, we didn't anticipate. Fortunately, with the knowledge we gained earlier, we'll be able to diagnose and fix them - live in production!

Attendees should be familiar with syntax and basic features of either *Elixir* or *Erlang*. It is advised that all attendees complete the *"Mix and OTP tutorial"* before the workshop. Link is here: http://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html

Participants should have `Elixir >= 1.5` and `Erlang >= 19.3` locally installed, together with their favourite editor.

## Editions

- [**ElixirConf US** (*Bellevue*, 2017)](https://elixirconf.com/speakers#gawronski)

## Prerequisites

- *Erlang* - verified with *19.3* and above.
- *Elixir* - verified with *1.5* and above.
- *Phoenix* - verified with *1.3* and above.
- *Absinthe* - verified with *1.4* and above.

For managing multiple *Erlang* and *Elixir* versions we recommend [asdf](https://github.com/asdf-vm/asdf).

## How to use this workshop?

### Moving through bugs

Explanation why and how to debug and narrow it down is inside [materials](#materials).

### Helpers

Feel free to use prepared helpers and scripts that will ease your pain when using this repository (please keep in mind that scripts requires `curl`, `jq` and `coreutils`). You will find them either inside application directory or inside `commands.md` file inside `helpers` directory.

## Materials

If you were on one of editions mentioned [above](#editions) you should receive materials after the workshop in a dedicated email from us.
Unfortunately rest of people will have to wait - *stay tuned*. :wink:

## Authors

- [@afronski](https://github.com/afronski)
- [@mentero](https://github.com/mentero)
- [@michalmuskala](https://github.com/michalmuskala)
