# Improved Dockerfile for better OS compatibility and security
FROM eclipse-temurin:17-jdk

WORKDIR /app

# Install curl for health checks
RUN apt-get update && \
    apt-get install -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN groupadd -r appuser && \
    useradd -r -g appuser appuser && \
    mkdir -p /app/logs && \
    chown -R appuser:appuser /app

# Copy the pre-built JAR (assumes target/spring-petclinic-*.jar exists)
COPY --chown=appuser:appuser target/spring-petclinic-*.jar app.jar

# Copy existing AppDynamics agent directory
COPY --chown=appuser:appuser appdynamics-agent/ appdynamics-agent/

# Create downloaded-agents directory (for future use)
RUN mkdir -p downloaded-agents && chown appuser:appuser downloaded-agents

# Copy entrypoint script
COPY --chown=appuser:appuser petclinic-entrypoint.sh petclinic-entrypoint.sh
RUN chmod +x petclinic-entrypoint.sh

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Default entrypoint (can be overridden by docker-compose)
ENTRYPOINT ["./petclinic-entrypoint.sh"]