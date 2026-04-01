# ============================================
# Stage 1: Build with Maven
# ============================================
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /build

# Copy pom files first for dependency caching
COPY pom.xml .
COPY bootstrap/pom.xml bootstrap/
COPY framework/pom.xml framework/
COPY infra-ai/pom.xml infra-ai/
COPY mcp-server/pom.xml mcp-server/

# Download dependencies (cached layer)
RUN mvn dependency:go-offline -B -q 2>/dev/null || true

# Copy source code
COPY bootstrap/src bootstrap/src
COPY framework/src framework/src
COPY infra-ai/src infra-ai/src
COPY mcp-server/src mcp-server/src
COPY resources/format resources/format
COPY lombok.config .

# Build (skip tests for speed)
RUN mvn clean package -DskipTests -B -q

# ============================================
# Stage 2: Runtime
# ============================================
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Add non-root user
RUN addgroup -S ragent && adduser -S ragent -G ragent

# Copy the built JAR
COPY --from=builder /build/bootstrap/target/bootstrap-*.jar app.jar

# Switch to non-root user
USER ragent

EXPOSE 9090

ENTRYPOINT ["java", "-jar", "app.jar"]
