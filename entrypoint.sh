#!/bin/sh

# Generate a self signed certificate if /var/ssl/haproxy.key does not exist
if [ ! -f /var/ssl/haproxy.pem ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /var/ssl/haproxy.key -out /var/ssl/haproxy.crt -subj "/C=US/ST=UT/L=Salt Lake City/O=Big Cartel/OU=IT Department/CN=*.bigcartel.test"
    cat /var/ssl/haproxy.key /var/ssl/haproxy.crt > /var/ssl/haproxy.pem
    rm /var/ssl/haproxy.{key,crt}
fi

exec "$@"
