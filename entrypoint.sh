#!/bin/sh
set -e

: "${SECRET_FRP_TOKEN:?SECRET_FRP_TOKEN environment variable must be set}"
: "${FRP_DASHBOARD_PASSWORD:?FRP_DASHBOARD_PASSWORD environment variable must be set}"

tmp_file="$(mktemp)"
envsubst '${SECRET_FRP_TOKEN} ${FRP_DASHBOARD_PASSWORD}' < /etc/frp/frps.ini > "${tmp_file}"
mv "${tmp_file}" /etc/frp/frps.ini

exec /usr/bin/frps -c /etc/frp/frps.ini
