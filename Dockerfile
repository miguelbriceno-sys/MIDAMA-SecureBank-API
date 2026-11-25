FROM node:24-bookworm-slim@sha256:e0e989b967dacc279681ed81774b2ce9eeebbb0efb8e0c427573235bebf1eda1 AS deps
WORKDIR /build
COPY package.json package-lock.json ./
RUN npm ci --omit=dev --ignore-scripts && mkdir -p node_modules

FROM gcr.io/distroless/nodejs24-debian13:nonroot@sha256:49559f4ee6632a11a13a7e198183efee1226de7a8f437df83c180b01bd8253ec
ENV NODE_ENV=production HOST=0.0.0.0 PORT=3000
WORKDIR /app
COPY --from=deps /build/node_modules ./node_modules
COPY package.json package-lock.json ./
COPY src ./src
USER 10001:10001
EXPOSE 3000
CMD ["src/server.js"]
