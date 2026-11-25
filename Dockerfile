FROM golang:1.26-bookworm AS builder

WORKDIR /src
COPY whatsapp-bridge/ .
RUN apt-get update && apt-get install -y gcc libsqlite3-dev && rm -rf /var/lib/apt/lists/*
RUN CGO_ENABLED=1 GOOS=linux go build -o /bin/whatsapp-bridge .

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y nginx ca-certificates sqlite3 && rm -rf /var/lib/apt/lists/*

COPY --from=builder /bin/whatsapp-bridge /bin/whatsapp-bridge

# nginx: forward external :8080 → internal bridge :9090
# Bridge only accepts loopback, so nginx runs on 0.0.0.0:8080 and proxies to 127.0.0.1:9090
RUN rm /etc/nginx/sites-enabled/default
COPY docker/nginx.conf /etc/nginx/conf.d/bridge.conf

COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

# Render persistent disk mounts at /data
ENV WHATSAPP_DB_PATH=/data/messages.db
ENV WHATSAPP_MEDIA_PATH=/data/media
ENV WHATSAPP_BACKUP_PATH=/data/backups
ENV WHATSAPP_AUDIT_LOG_PATH=/data/audit.log
# Bridge binds loopback internally; nginx handles public traffic
ENV WHATSAPP_BRIDGE_HOST=127.0.0.1
ENV WHATSAPP_BRIDGE_PORT=9090
ENV WHATSAPP_ENCRYPT_DB=true

EXPOSE 8080

CMD ["/start.sh"]
