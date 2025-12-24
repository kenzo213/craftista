FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

COPY pom.xml .
COPY src ./src
RUN mvn -q -DskipTests package

# Final stage
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

RUN addgroup -S app && adduser -S app -G app

COPY --from=build /app/target/*.jar app.jar

RUN chown app:app app.jar

USER app
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --retries=3 --start-period=60s \
    CMD wget -qO- http://localhost:8080/api/origamis || exit 1

CMD ["java", "-jar", "app.jar"]
