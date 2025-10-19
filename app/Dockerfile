FROM eclipse-temurin:17-jre-alpine AS base
WORKDIR /app

FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /src
COPY pom.xml ./
RUN mvn -q -B -e -DskipTests dependency:go-offline
COPY src ./src
RUN mvn -q -B -DskipTests package

FROM gcr.io/distroless/java17-debian12
WORKDIR /app
COPY --from=build /src/target/autovyn-app-*.jar /app/app.jar
EXPOSE 8080
USER 65532:65532
ENTRYPOINT ["/usr/bin/java", "-jar", "/app/app.jar"]
