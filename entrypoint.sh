#!/bin/sh
# データディレクトリの初期化
mkdir -p /app/data

# スケジューラをバックグラウンドで起動
node scripts/scripts/scheduler.js &

# Next.jsを起動
exec node server.js
