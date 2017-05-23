/*
Copyright 2017 wgawronski@white-rook.pl

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
USE OR OTHER DEALINGS IN THE SOFTWARE. HERE BE DRAGONS. AND SEGFAULTS. I AM WONDERING
IF SOMEONE ACTUALLY READING HEADERS. THIS IS NOT A DRILL. ALL YOUR BASE ARE BELONG TO US.
*/

#include <time.h>
#include <stdio.h>
#include <string.h>
#include <erl_nif.h>

const char* SENTENCES[] = {
  "It is certain",
  "It is decidedly so",
  "Without a doubt",
  "Yes definitely",
  "You may rely on it",
  "As I see it, yes",
  "Most likely",
  "Outlook good",
  "Yes",
  "Signs point to yes",
  "Reply hazy try again",
  "Ask again later",
  "Better not tell you now",
  "Cannot predict now",
  "Concentrate and ask again",
  "Don't count on it",
  "My reply is no",
  "My sources say no",
  "Outlook not so good",
  "Very doubtful"
};

static int load(ErlNifEnv* env, void **priv, ERL_NIF_TERM info)
{
  srand(time(NULL));
  return 0;
}

static int reload(ErlNifEnv* env, void** priv, ERL_NIF_TERM info)
{
  return 0;
}

static int upgrade(ErlNifEnv* env, void** priv, void** old_priv, ERL_NIF_TERM info)
{
  *priv = *old_priv;
  return 0;
}

static void unload(ErlNifEnv* env, void* priv)
{
}

char* alloc_and_copy_to_cstring(ErlNifBinary *string)
{
  char* str = (char*) enif_alloc(string->size + 1);
  strncpy(str, (char*) string->data, string->size);

  str[string->size] = 0;

  return str;
}

int random_from_range(int min, int max) {
  return rand() % (max + 1 - min) + min;
}

static ERL_NIF_TERM question(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  ErlNifBinary string;

  enif_inspect_binary(env, argv[0], &string);

  char* question = alloc_and_copy_to_cstring(&string);

  char last_character = question[strlen(question) - 1];

  if (last_character != '?') {
    return enif_make_atom(env, "not_a_question");
  }

  int words = 0;
  char* chunk = strtok(question, " ");

  while(chunk != NULL) {
    ++words;
    chunk = strtok(NULL, " ");
  }

  int position = random_from_range(0, words);
  const char* answer = SENTENCES[position];

  return enif_make_tuple2(env, enif_make_atom(env, "ok"), enif_make_string(env, answer, ERL_NIF_LATIN1));
}

static ErlNifFunc functions[] = {
  {"question", 1, question}
};

ERL_NIF_INIT(Elixir.MagicEightBall.Logic, functions, &load, &reload, &upgrade, &unload)