# syntax = docker/dockerfile:1

ARG NODE_VERSION=22
FROM node:${NODE_VERSION}-slim as base

LABEL fly_launch_runtime="NodeJS"

WORKDIR /app
ENV NODE_ENV=production

FROM base as build

RUN apt-get update -qq && \
    apt-get install -y python-is-python3 pkg-config build-essential

COPY --link package.json package-lock.json ./
RUN npm install --production=false --legacy-peer-deps

COPY --link . .
RUN npm prune --production

FROM base

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends curl gnupg ca-certificates && \
    curl -fsSL https://pgp.mongodb.com/server-7.0.asc | gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor && \
    echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] http://repo.mongodb.org/apt/debian bookworm/mongodb-org/7.0 main" \
      > /etc/apt/sources.list.d/mongodb-org-7.0.list && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends mongodb-org && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=build /app /app
COPY scripts/fly-start.sh /app/scripts/fly-start.sh
RUN chmod +x /app/scripts/fly-start.sh

# Persistent DB when mounted at /data/db (see fly.toml)
VOLUME ["/data/db"]

CMD ["/app/scripts/fly-start.sh"]
