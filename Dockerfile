FROM node:24.22.1-slim

RUN npm install -g pnpm@12.16.1

WORKDIR /app

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
