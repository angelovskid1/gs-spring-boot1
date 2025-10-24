# syntax=docker/dockerfile:1.6

# Stage 1: build with JDK 21
FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /app

# Download deps first (cached)
COPY pom.xml .
RUN --mount=type=cache,target=/root/.m2 mvn -B -q -DskipTests dependency:go-offline

# Build
COPY src ./src
RUN --mount=type=cache,target=/root/.m2 mvn -B -DskipTests clean package

# Stage 2: slim runtime with JRE 21
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
