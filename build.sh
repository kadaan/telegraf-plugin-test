#!/usr/bin/env bash

function run() {
  dep ensure -v --vendor-only || exit 1
  CGO_ENABLED=1 go build -buildmode=plugin . || exit 1
}

run "$@"
