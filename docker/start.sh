#!/bin/bash
set -e

mkdir -p /data/media /data/backups

# Start nginx first so Render detects port 8080 immediately
nginx

# Wait for nginx to be ready
sleep 2

# Start whatsapp bridge in foreground
exec /bin/whatsapp-bridge
