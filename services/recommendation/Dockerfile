FROM golang:1.23-alpine AS build

WORKDIR /src

COPY go.mod go.sum* ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 go build -o /out/app .

# Final stage
FROM alpine:latest

WORKDIR /app

RUN addgroup -S app && adduser -S app -G app

COPY --from=build /out/app /app/recommendation
COPY config.json .
COPY templates ./templates
COPY static ./static

RUN chown -R app:app /app

USER app
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD wget -qO- http://localhost:8080/ || exit 1

CMD ["./recommendation"]
