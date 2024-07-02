FROM node:22.3.0-slim

WORKDIR /app

COPY package.json yarn.lock ./

RUN yarn install

COPY . .

