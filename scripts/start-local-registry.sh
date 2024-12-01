#!/usr/bin/env bash

if [ $(docker ps --filter "NAME=registry" --format json | jq '.Image' -r) = "registry:2" ]; then
    echo "Docker registry is running"
else
    docker run -d -p 5000:5000 --restart=always --name registry registry:2
fi
