FROM golang:1.23-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /out/app .

FROM gcr.io/distroless/static:nonroot
WORKDIR /app
COPY --from=build /out/app .
COPY --from=build /src/templates ./templates
COPY --from=build /src/static ./static
EXPOSE 8080
USER nonroot:nonroot
ENTRYPOINT ["./app"]
