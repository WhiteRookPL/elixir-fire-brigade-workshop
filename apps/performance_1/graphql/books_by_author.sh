#!/usr/bin/env bash

AUTHOR=${1:-"Dmitry Glukhovsky"}

curl -X POST -s -d "{ booksByAuthor(author: \"${AUTHOR}\") { title, id } }" "http://localhost:8080/api" | jq