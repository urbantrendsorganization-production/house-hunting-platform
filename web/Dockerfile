# Keja website — Next.js 15 (Phase 5) production image.
#
# Multi-stage + standalone output => a lean runtime image (node + .next only).
#
# IMPORTANT: NEXT_PUBLIC_* values are INLINED into the client bundle at
# `next build` time, so they are passed as build ARGs (not runtime env). The
# prod compose forwards them from .env. Server-side fetches use API_BASE, which
# IS read at runtime (see next.config.ts) and stays a plain env var.

# syntax=docker/dockerfile:1

# --- deps: install node_modules from the lockfile ---
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# --- builder: compile the standalone server bundle ---
FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Client-inlined public config — must exist at build time.
ARG NEXT_PUBLIC_API_BASE
ARG NEXT_PUBLIC_SITE_URL
ARG NEXT_PUBLIC_GOOGLE_MAPS_KEY
ARG NEXT_PUBLIC_PLAY_STORE_URL
ARG NEXT_PUBLIC_CONSUMER_APK_URL
ARG NEXT_PUBLIC_AGENT_APK_URL
ENV NEXT_PUBLIC_API_BASE=$NEXT_PUBLIC_API_BASE \
    NEXT_PUBLIC_SITE_URL=$NEXT_PUBLIC_SITE_URL \
    NEXT_PUBLIC_GOOGLE_MAPS_KEY=$NEXT_PUBLIC_GOOGLE_MAPS_KEY \
    NEXT_PUBLIC_PLAY_STORE_URL=$NEXT_PUBLIC_PLAY_STORE_URL \
    NEXT_PUBLIC_CONSUMER_APK_URL=$NEXT_PUBLIC_CONSUMER_APK_URL \
    NEXT_PUBLIC_AGENT_APK_URL=$NEXT_PUBLIC_AGENT_APK_URL \
    NEXT_TELEMETRY_DISABLED=1

RUN npm run build

# --- runner: minimal runtime ---
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    PORT=3000 \
    HOSTNAME=0.0.0.0

RUN addgroup -S nodejs && adduser -S nextjs -G nodejs

# Standalone output bundles a minimal server.js + only the deps it traced.
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000
CMD ["node", "server.js"]
