#!/usr/bin/env bash

curl -X POST -s -d "{ authors { id, name, surname } }" "http://localhost:8080/api" | jq