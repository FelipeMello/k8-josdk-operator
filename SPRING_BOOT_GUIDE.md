# JOSDK + Spring Boot Operator

## Overview
This project combines **Java Operator SDK (JOSDK)** with **Spring Boot**, which is an excellent and recommended approach for building Kubernetes operators.

## Why Spring Boot + JOSDK? ✅

### ✅ **Advantages:**
1. **Dependency Injection** - Spring automatically manages and injects beans (KubernetesClient, custom services, etc.)
2. **Configuration Management** - Use `application.yml` for operator configuration
3. **Actuators & Monitoring** - Built-in `/actuator` endpoints for health, metrics, readiness probes
4. **Logging** - SLF4J + Logback for structured, configurable logging
5. **Testing** - Spring Boot test framework for integration testing
6. **REST APIs** - Easy to add HTTP endpoints for operator management
7. **External Services** - Simple integration with other Spring Boot services

### ⚠️ **Considerations:**
- Spring Boot adds ~50-100MB to JAR size
- Startup time ~2-3 seconds (vs ~500ms for pure operator)
- Memory footprint slightly higher due to Spring context initialization
- **Still recommended** for most use cases - benefits outweigh tradeoffs

## Project Structure

```
src/main/java/com/k8/josdkoperator/
├── JosdkOperatorApplication.java      # Spring Boot main entry point
├── WebPageReconciler.java              # Your operator reconciler
├── customresource/                     # Custom Resource Definitions
│   ├── WebPage.java                   # CRD
│   ├── WebPageSpec.java               # Spec definition
│   └── WebPageStatus.java             # Status definition
└── config/
    └── KubernetesClientConfig.java    # Spring configuration bean

src/main/resources/
└── application.yml                     # Spring Boot configuration
```

## Running the Operator

### Local Development
```bash
# Build
./mvnw clean install

# Run (requires Kubernetes cluster or kubeconfig)
./mvnw spring-boot:run

# With specific log level
./mvnw spring-boot:run -Dspring-boot.run.arguments="--logging.level.com.k8.josdkoperator=DEBUG"
```

### Docker Deployment
```dockerfile
FROM eclipse-temurin:25-jdk-alpine
COPY target/josdkoperator-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
```

### Kubernetes Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: josdk-operator
spec:
  replicas: 1
  selector:
    matchLabels:
      app: josdk-operator
  template:
    metadata:
      labels:
        app: josdk-operator
    spec:
      serviceAccountName: josdk-operator
      containers:
      - name: operator
        image: josdk-operator:latest
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /actuator/health/liveness
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
```

## Configuration

Edit `src/main/resources/application.yml`:

```yaml
spring:
  application:
    name: josdk-operator

# Add custom operator properties
operator:
  namespace: default              # Watch specific namespace
  resyncInterval: 30000          # Resync period in milliseconds
  maxConcurrentReconciliations: 5
```

## Actuator Endpoints

Once running, access operator health info:

```bash
# Health check
curl http://localhost:8080/actuator/health

# Metrics
curl http://localhost:8080/actuator/metrics

# Environment
curl http://localhost:8080/actuator/env
```

## Adding More Reconcilers

1. Create a new CustomResource class extending `CustomResource`
2. Create a Reconciler implementing `Reconciler<YourResource>`
3. Annotate with `@Component` and `@ControllerConfiguration`
4. Spring will automatically register it on startup

```java
@Component
@ControllerConfiguration
public class MyResourceReconciler implements Reconciler<MyResource> {
    // Implementation
}
```

## Troubleshooting

- **RBAC Issues**: Ensure service account has proper permissions
- **CRD Registration**: CRDs should be installed before operator runs
- **Kubeconfig**: Set `KUBECONFIG` env var or use in-cluster config
- **Logs**: Check Spring logs: `./mvnw spring-boot:run -Dlogging.level.root=DEBUG`

## Best Practices ✅

✅ Use Spring Beans for dependency injection  
✅ Configure via `application.yml`, not hardcoding  
✅ Add health checks with Spring Actuator  
✅ Use Spring profiles for different environments (dev, prod)  
✅ Implement proper error handling and retries  
✅ Monitor operator metrics  
✅ Use structured logging (SLF4J)  

## References
- [Java Operator SDK Docs](https://javaoperatorsdk.io)
- [Spring Boot Docs](https://spring.io/projects/spring-boot)
- [Fabric8 Kubernetes Client](https://github.com/fabric8io/kubernetes-client)

