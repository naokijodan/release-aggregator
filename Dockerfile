# ---- builder ----
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci

COPY . .

RUN npx next build

# スクリプト用TypeScriptをコンパイル
RUN npx tsc -p tsconfig.scripts.json || true

# standalone モードの server.js を利用するため、必要ファイルを整理
# Next.js の output: 'standalone' が設定されている前提

# ---- runner ----
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV RSSHUB_URL=http://rsshub:1200
ENV CHANGEDETECTION_URL=http://changedetection:5000

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Next.js standalone output をコピー
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# コンパイル済みスケジューラスクリプトをコピー
COPY --from=builder /app/scripts-dist ./scripts

# entrypoint をコピー
COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

# データディレクトリを作成（ボリュームマウントポイント）
RUN mkdir -p /app/data && chown nextjs:nodejs /app/data

VOLUME ["/app/data"]

EXPOSE 3000

USER nextjs

ENTRYPOINT ["./entrypoint.sh"]
