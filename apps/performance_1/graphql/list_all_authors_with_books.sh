#!/usr/bin/env bash

curl -X POST -s -d "{ authors { id, name, surname, books { id, title } } }" "http://localhost:8080/api" | jq