# setup build arguments for version of dependencies to use
ARG DOCKER_GEN_VERSION=0.9.0

# Use a specific version of golang to build both binaries
FROM golang:1.19-alpine as gobuilder
RUN apk add --no-cache git musl-dev

# Build docker-gen from scratch
FROM gobuilder as dockergen

ARG DOCKER_GEN_VERSION

RUN git clone https://github.com/nginx-proxy/docker-gen \
   && cd /go/docker-gen \
   && git -c advice.detachedHead=false checkout $DOCKER_GEN_VERSION \
   && go mod download \
   && CGO_ENABLED=0 go build -ldflags "-X main.buildVersion=${DOCKER_GEN_VERSION}" ./cmd/docker-gen \
   && go clean -cache \
   && mv docker-gen /usr/local/bin/ \
   && cd - \
   && rm -rf /go/docker-gen

FROM haproxy:2.6-alpine

USER root

ENV DOCKER_HOST unix:///tmp/docker.sock

RUN apk add --no-cache openssl

RUN mkdir /var/ssl

COPY --from=dockergen /usr/local/bin/docker-gen /usr/local/bin/docker-gen

COPY haproxy.tmpl docker-gen.cfg entrypoint.sh /app/

WORKDIR /app

ENTRYPOINT ["/app/entrypoint.sh"]

CMD ["docker-gen", "-config", "/app/docker-gen.cfg"]
