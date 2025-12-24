FROM node:20-alpine

WORKDIR /app

ENV NODE_ENV=production
RUN addgroup -S app && adduser -S app -G app

COPY package*.json ./
RUN npm install --production && npm cache clean --force

COPY . .

RUN chown -R app:app /app

USER app
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD wget -qO- http://localhost:3000/ || exit 1

CMD ["node", "app.js"]
