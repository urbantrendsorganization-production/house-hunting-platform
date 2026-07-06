# web — Keja website (Next.js 15)

SEO-first map experience for "vacant houses in <estate>" queries. App Router,
TypeScript strict, server components by default.

## Surfaces

- `/` — homepage: estates with live vacant counts (SSR).
- `/vacant-houses/[estate]` — **SSR estate pages** (the SEO target) with ItemList
  JSON-LD, per-building price + "verified X days ago" badges. SSG + ISR (60s).
- `/building/[id]` — building detail + Google Maps directions deep-link (SSR).
- `/map` — interactive Google Maps view driven by the viewport API; debounced
  refetch on pan/zoom, server-side clusters. Degrades to a list without a key.

Freshness rule is honoured everywhere: the API hides >30d listings, so they
never reach these pages, and every card carries its verified age.

## Develop

```bash
cp .env.example .env.local     # point API_BASE at the running Django API
npm install
npm run dev                    # http://localhost:3000
```

The Django API must be running (see repo root README). SSR pages fetch from
`API_BASE`; the browser map uses `NEXT_PUBLIC_API_BASE`.

## Build / verify

```bash
npm run typecheck
npm run build
```
