#!/usr/bin/env bash

curl -X POST -s -d "{ books { title, id } }" "http://localhost:8080/api" | jq