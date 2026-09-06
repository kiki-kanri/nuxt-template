# syntax=docker/dockerfile:labs

# Build stage
FROM ghcr.io/pnpm/pnpm:12 AS build-stage

## Install Node.js for the build
RUN pnpm runtime set node 26 -g

## Configure build-time options and the environment
ARG PNPM_CONFIG_REGISTRY
ENV NODE_ENV='production' \
    PNPM_CONFIG_REGISTRY="${PNPM_CONFIG_REGISTRY}"

WORKDIR /app

## Copy dependency manifests and install dependencies
COPY ./package.json ./pnpm-lock.yaml ./pnpm-workspace.yaml ./
RUN --mount=id=pnpm-store,target=/pnpm/store,type=cache \
    pnpm i --frozen-lockfile

## Configure options used by the application build
# ARG
# ENV

## Copy application sources and build the application
COPY --exclude=./docker-entrypoint.sh ./ ./
RUN pnpm run lint && \
    pnpm run typecheck && \
    pnpm run build

# Runtime stage
FROM node:26-slim

## Configure the runtime environment and working directory
ENV TZ='UTC'
WORKDIR /app

## Install runtime packages and configure the runtime user
RUN \
    ### Upgrade system packages and install runtime dependencies
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends tini tzdata && \
    ### Configure the timezone
    ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime && \
    echo "${TZ}" >/etc/timezone && \
    ### Clean package manager metadata
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/cache/apt/* /var/lib/apt/lists/* && \
    ### Create the runtime user and set application ownership
    useradd -mr -g nogroup -s /usr/sbin/nologin -u 10001 user && \
    chown 10001:nogroup /app -R

## Copy and configure the entrypoint
COPY --chmod=700 --chown=10001:nogroup ./docker-entrypoint.sh ./
USER 10001
ENTRYPOINT ["tini", "--"]
CMD ["./docker-entrypoint.sh"]

## Configure remaining runtime defaults
ENV NODE_ENV='production'

## Copy the application output
COPY --chown=10001:nogroup --from=build-stage /app/.output ./
