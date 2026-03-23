#!/bin/bash
echo "🚀 リリース速報Pro を起動します..."
echo ""
echo "初回起動は数分かかる場合があります。"
echo ""

docker compose up -d

echo ""
echo "✅ 起動完了！"
echo ""
echo "📱 アプリ:        http://localhost:3000"
echo "📡 RSSHub:        http://localhost:1200"
echo "🔍 変更監視:      http://localhost:5050"
echo ""
echo "停止するには: docker compose down"
