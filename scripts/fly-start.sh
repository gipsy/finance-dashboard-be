#!/bin/bash
set -euo pipefail

DB_PATH="${MONGO_DB_PATH:-/data/db}"
mkdir -p "$DB_PATH"
chown -R mongodb:mongodb "$DB_PATH" 2>/dev/null || true

mongod --bind_ip 127.0.0.1 --dbpath "$DB_PATH" --fork --logpath /var/log/mongod.log

export MONGO_URL="${MONGO_URL:-mongodb://127.0.0.1:27017/finance-dashboard}"
export PORT="${PORT:-8080}"

exec npm start
