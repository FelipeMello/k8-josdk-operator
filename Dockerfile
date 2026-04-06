# Multi-stage build for optimal image size
FROM eclipse-temurin:25-jdk-alpine AS builder

WORKDIR /build
COPY pom.xml ./
COPY .mvn .mvn
COPY mvnw ./

# Download dependencies (cached if pom.xml unchanged)
RUN ./mvnw dependency:go-offline -B

COPY src ./src
# Build the application
RUN ./mvnw clean package -DskipTests -B

# Runtime stage - minimal image
FROM eclipse-temurin:25-jre-alpine

# Add non-root user for security
RUN addgroup -g 1001 -S appuser && \
    adduser -u 1001 -S appuser -G appuser

WORKDIR /app

# Copy the built JAR from builder stage
COPY --from=builder /build/target/josdkoperator-*.jar app.jar

# Change ownership to non-root user
RUN chown -R appuser:appuser /app
USER appuser

# Expose port for actuator endpoints (optional)
EXPOSE 8080

# Set JVM options for container optimization
ENV JAVA_OPTS="-Xmx256m -Xms128m -XX:+UseG1GC -XX:+UseContainerSupport"

# Health check (optional)
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
