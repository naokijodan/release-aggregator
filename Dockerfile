# ---- builder ----
FROM node:20-alpine AS builder

WORKDIR /app

# app/ ディレクトリの内容をコピー
COPY app/package.json app/package-lock.json* ./
RUN npm ci

COPY app/ .

# Next.js ビルド（standalone出力）
RUN npx next build

# スクリプト用TypeScriptをコンパイル
RUN npx tsc -p tsconfig.scripts.json

# ---- runner ----
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV RSSHUB_URL=http://rsshub:1200
ENV CHANGEDETECTION_URL=http://changedetection:5000

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs && \
    apk add --no-cache su-exec

# Next.js standalone output をコピー
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# コンパイル済みスケジューラスクリプトをコピー
COPY --from=builder /app/scripts-dist ./scripts

# rss-parser等のnpmパッケージが必要なのでnode_modulesもコピー
COPY --from=builder /app/node_modules ./node_modules

# entrypoint をコピー
COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

# データディレクトリを作成（ボリュームマウントポイント）
RUN mkdir -p /app/data && chown nextjs:nodejs /app/data

VOLUME ["/app/data"]

EXPOSE 3000

ENTRYPOINT ["./entrypoint.sh"]
