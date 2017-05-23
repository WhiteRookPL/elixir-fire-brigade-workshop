#!/usr/bin/env bash

AUTHOR=${1:-"Dmitry Glukhovsky"}

curl -X POST -s -d "mutation createAuthor { createAuthorWithMixedData(name_and_surname: \"${AUTHOR}\") { id } }" "http://localhost:8080/api" | jq