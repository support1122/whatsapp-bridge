#!/bin/bash
set -e

mkdir -p /data/media /data/backups

# Start nginx in background
nginx -g "daemon off;" &

# Start whatsapp bridge
exec /bin/whatsapp-bridge
