#!/usr/bin/env bash

AUTHOR=${1:-"Dmitry Glukhovsky"}
TITLE=${2:-"Metro 2033"}

curl -X POST -s -d "mutation associateBookWithAuthor { associateBookWithAuthor(title: \"${TITLE}\", author: \"${AUTHOR}\") { id } }" "http://localhost:8080/api" | jq