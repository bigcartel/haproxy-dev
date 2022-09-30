# Haproxy-dev

This is a lightweight reverse proxy for docker-compose development environments using docker-gen to generate the haproxy.cfg. It builds off the work of jwilder/nginx-proxy

It's pretty limited in it's feature set, simply alowing ACLs to be configured for each service to configure routes. Here's an example:

## Docker Compose
```
version: '2'

services:
  haproxy-dev:
    image: bigcartel/haproxy-dev:latest
    ports:
      - "80:80"
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro

  whoami:
    labels:
      haproxy_port: 8000 # optional, if more than one port is exposed
      haproxy_acls: |
        acl my_hosts hdr_end(host) -i whoami.test
        use_backend whoami if my_hosts
    image: jwilder/whoami
    expose:
      - "8000"
```

## Building
`docker buildx build . -t bigcartel/haproxy-dev:latest --platform linux/amd64,linux/arm64 --push`
