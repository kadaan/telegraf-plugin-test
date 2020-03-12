FROM ubuntu:18.04
ENV GOPATH=/go CGO_ENABLED=1 GOOS=linux GOARCH=amd64
RUN apt update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:longsleep/golang-backports && \
    apt update && \
    apt-get install -y build-essential curl git golang-1.13-go go-dep && \
    mkdir /dist && \
    mkdir -p /go/bin && \
    mkdir -p /go/src/github.com/kadaan && \
    mkdir -p /go/src/github.com/influxdata
WORKDIR /go/src/github.com/kadaan
RUN git clone https://github.com/kadaan/telegraf-plugin-test
WORKDIR /go/src/github.com/kadaan/telegraf-plugin-test
RUN dep ensure -v --vendor-only && \
    /usr/lib/go-1.13/bin/go build -buildmode=plugin -o /dist/telegraf-plugin.so
WORKDIR /go/src/github.com/influxdata
RUN git clone https://github.com/influxdata/telegraf.git
WORKDIR /go/src/github.com/influxdata/telegraf
COPY ./telegraf.patch .
RUN git checkout tags/1.13.4 -b v1.13.4 && \
    git apply --verbose telegraf.patch && \
    dep ensure -v --vendor-only && \
    /usr/lib/go-1.13/bin/go build -o /dist/telegraf -tags goplugin -ldflags "-X main.version=1.13.4 -X main.commit=$(git rev-parse HEAD) -X main.branch=$(git rev-parse --abbrev-ref HEAD)" ./cmd/telegraf
RUN /usr/lib/go-1.13/bin/go version
WORKDIR /dist
COPY ./telegraf.conf .
RUN echo "/dist/telegraf --config /dist/telegraf.conf --plugin-directory /dist --test" > /dist/run_telegraf.sh && \
    chmod +x /dist/run_telegraf.sh && \
    /dist/run_telegraf.sh
ENTRYPOINT ["/bin/bash"]