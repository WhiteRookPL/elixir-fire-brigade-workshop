#include <erl_nif.h>

static ERL_NIF_TERM explode(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    int *an_integer = NULL;
    *an_integer = 100;
    return enif_make_atom(env, "ok");
};

static int load(ErlNifEnv* env, void **priv, ERL_NIF_TERM info)
{
    return 0;
};

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

static ErlNifFunc funcs[] =
{
    {"explode", 0, explode}
};

ERL_NIF_INIT(Elixir.TreasureHunt.Bomb, funcs, &load, &reload, &upgrade, &unload);