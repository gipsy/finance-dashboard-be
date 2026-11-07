# Finance Dashboard — Backend API

> Node.js REST service that stores and serves finance data for the Finance Dashboard web app.

## About this project

**Finance Dashboard** is a small full-stack application for exploring company finances in one place. **This repository** is the server side: it exposes a read-focused JSON API, persists documents in **MongoDB**, and ships with sample seed data so a new database is usable immediately.

| Repository | Role |
|------------|------|
| [finance-dashboard-fe](https://github.com/gipsy/finance-dashboard-fe) | React/Vite SPA — charts, grids, and revenue forecasting |
| **This repo** ([finance-dashboard-be](https://github.com/gipsy/finance-dashboard-be)) | Express API, Mongoose models, optional Docker / Fly.io deployment |

**Data model (three collections):**

- **KPIs** — aggregate totals, expense categories, and monthly/daily revenue & expense series used for trend and pie charts.
- **Products** — catalog items with cost, price, and margin fields for the product table.
- **Transactions** — recent sales linked to products (latest 50 returned by the API).

Amounts are stored in USD **cents** via `mongoose-currency` and exposed in JSON as dollar values through Mongoose getters. **CORS** is enabled so the Vercel-hosted frontend can call the API from the browser.

On first connect, if the database is empty, the server loads fixtures from `data/data.js` (same sample set used in development).

**Live API:** [old-sound-6213.fly.dev](https://old-sound-6213.fly.dev) — pairs with [finance-dashboard-fe.vercel.app](https://finance-dashboard-fe.vercel.app).

## Features

- JSON REST API with CORS enabled for browser clients
- Security middleware: Helmet, structured logging (Morgan)
- MongoDB models for KPIs, products, and transactions
- Sample seed data in `data/data.js` (loaded automatically when the database is empty)
- Docker image and [Fly.io](https://fly.io) config for deployment

## API endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/kpi/kpis` | All KPI documents (totals, categories, monthly/daily series) |
| `GET` | `/product/products` | All products |
| `GET` | `/transaction/transactions` | Latest 50 transactions (newest first) |

Default port: **9000** locally, **8080** when deployed per `fly.toml`.

## Prerequisites

- Node.js 20+ (22 recommended; see `Dockerfile`)
- MongoDB instance and connection string

## Setup

1. Clone the repository and install dependencies:

   ```bash
   npm install
   ```

   > `mongoose-currency` declares a Mongoose 4 peer dependency; this project uses Mongoose 7. Run `npm install --legacy-peer-deps`, or add `legacy-peer-deps=true` in a local `.npmrc` (gitignored).

2. Copy the example env file and adjust if needed:

   ```bash
   cp .env.example .env
   ```

3. Run the server:

   ```bash
   npm run dev    # development (nodemon)
   npm start      # production
   ```

## Docker

```bash
docker build -t finance-dashboard-be .
docker run -p 9000:8080 -e MONGO_URL="..." finance-dashboard-be
```

## Fly.io

| App | Role | Config |
|-----|------|--------|
| `old-sound-6213` | Node API (bundled MongoDB via `scripts/fly-start.sh`, volume at `/data/db`) | `fly.toml` |
| `finance-dashboard-mongo` | Standalone MongoDB (optional; private `.internal` hostname) | `fly.mongo.toml` |

Production API: https://old-sound-6213.fly.dev — pairs with the [finance-dashboard-fe](https://github.com/gipsy/finance-dashboard-fe) Vercel frontend.

Local access to the Fly Mongo app:

```bash
fly proxy 27017:27017 -a finance-dashboard-mongo
```

## Project layout

```
index.js              # App entry, middleware, MongoDB connection, auto-seed
routes/               # KPI, product, transaction routers
models/               # Mongoose schemas
data/data.js          # Sample seed documents
scripts/fly-start.sh  # Fly entry: local mongod + Node server
```

## License

ISC
