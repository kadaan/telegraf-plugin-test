#!/usr/bin/env bash
set -x
BUILD_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

function build_external_plugin() {
  dep ensure -v --vendor-only || exit 1
  CGO_ENABLED=1 go build -buildmode=plugin -o $BUILD_DIR/telegraf-plugin.so . || exit 1
}

function build_telegraf() {
  local tmp_dir
  tmp_dir=$(mktemp -d -t telegraf-XXXXXXXXXX) || exit 1
  mkdir -p $tmp_dir/go/src/github.com/influxdata || exit 1
  trap "rm -rf $tmp_dir" EXIT
  pushd $tmp_dir/go/src/github.com/influxdata || exit 1
  git clone https://github.com/influxdata/telegraf.git || exit 1
  pushd telegraf || exit 1
  git checkout tags/1.13.4 -b v1.13.4 || exit 1
  git apply --verbose $BUILD_DIR/telegraf.patch || exit 1
  GOPATH=$tmp_dir/go dep ensure -v --vendor-only || exit 1
  GOPATH=$tmp_dir/go CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -o $BUILD_DIR/telegraf -tags goplugin -ldflags "-X main.version=1.13.4 -X main.commit=$(git rev-parse HEAD) -X main.branch=$(git rev-parse --abbrev-ref HEAD)" ./cmd/telegraf || exit 1
  popd || exit 1
  popd || exit 1
}

function run_telegraf() {
  $BUILD_DIR/telegraf --config $BUILD_DIR/telegraf.conf --plugin-directory $BUILD_DIR --test || exit 1
}

function run() {
  build_external_plugin || exit 1
  build_telegraf || exit 1
  run_telegraf || exit 1
}

run "$@"
