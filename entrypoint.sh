#!/bin/sh
# データディレクトリの初期化と権限設定
mkdir -p /app/data
chown -R nextjs:nodejs /app/data 2>/dev/null || true
chmod -R 755 /app/data 2>/dev/null || true

# スケジューラをバックグラウンドで起動
su-exec nextjs node scripts/scripts/scheduler.js &

# Next.jsを起動
exec su-exec nextjs node server.js
