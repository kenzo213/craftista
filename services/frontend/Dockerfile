# --- build stage ---
FROM node:20-alpine AS build
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
# No build step needed for this Express app

# --- runtime stage ---
FROM node:20-alpine
WORKDIR /app

ENV NODE_ENV=production
RUN addgroup -S app && adduser -S app -G app

COPY --from=build /app/package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --from=build /app .

USER app
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD wget -qO- http://localhost:3000 || exit 1

CMD ["node", "app.js"]

