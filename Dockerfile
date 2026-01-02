FROM node:25.2.1-slim

RUN npm install -g pnpm@10.26.2

WORKDIR /app

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
