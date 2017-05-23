MIX = mix
CFLAGS = -O3

ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
ERLANG_DIRTY_SCHEDULERS = $(shell erl -eval 'io:format("~s", [try erlang:system_info(dirty_cpu_schedulers), true catch _:_ -> false end])' -s init stop -noshell)
CFLAGS += -I$(ERLANG_PATH)

ifndef MIX_ENV
	$(error MIX_ENV is required)
endif

ifneq ($(OS),Windows_NT)
	CFLAGS += -fPIC
endif

ifeq ($(shell uname),Darwin)
	LDFLAGS += -dynamiclib -undefined dynamic_lookup
endif

ifeq ($(ERLANG_DIRTY_SCHEDULERS),true)
	CFLAGS += -DERTS_DIRTY_SCHEDULERS
endif

ifdef DEBUG
	CFLAGS += -DNIFSY_DEBUG -pedantic -Weverything -Wall -Wextra -Wno-unused-parameter -Wno-gnu
endif

ifeq ($(MIX_ENV),dev)
	CFLAGS += -g
endif

ifeq ($(MIX_ENV),test)
	CFLAGS += -g
endif

.PHONY: all clean

all: priv/$(MIX_ENV)/bomb.so

priv/$(MIX_ENV)/bomb.so: c_src/bomb.c
	mkdir -p priv/$(MIX_ENV)
	$(CC) $(CFLAGS) -shared $(LDFLAGS) -o $@ c_src/bomb.c

clean:
	$(RM) -r priv/$(MIX_ENV)
