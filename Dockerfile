FROM eclipse-temurin:25-jdk-alpine

WORKDIR /app

# Copy the built JAR file
COPY target/josdkoperator-0.0.1-SNAPSHOT.jar app.jar

# Expose port for actuator endpoints (optional)
EXPOSE 8080

# Set JVM options for container
ENV JAVA_OPTS="-Xmx256m -Xms128m -XX:+UseG1GC"

# Run the application
ENTRYPOINT ["java"]
CMD ["-jar", "/app/app.jar"]

