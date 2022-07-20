#!/bin/bash
set -e

export APP_ENV="${APP_ENV:-default}"

echo resolver $(awk 'BEGIN{ORS=" "} $1=="nameserver" {print $2}' /etc/resolv.conf) " valid=10s;" > /etc/nginx/resolvers.conf

# Replace varialbes on nginx.conf template
sed -e 's@{{API_UPSTREAM}}@'$API_UPSTREAM'@' /tmp/nginx.template > /etc/nginx/nginx.conf

echo "Starging nginx. Upstream: ${API_UPSTREAM}"
nginx -g 'daemon off;'