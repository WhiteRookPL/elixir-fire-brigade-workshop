#!/usr/bin/env bash

TITLE=${1:-"Metro 2033"}

curl -X POST -s -d "mutation createBook { createBook(title: \"${TITLE}\") { id } }" "http://localhost:8080/api" | jq