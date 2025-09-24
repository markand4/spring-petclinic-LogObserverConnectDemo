#!/bin/bash
set -e

echo "Starting PetClinic application..."
echo "Current user: $(whoami)"
echo "Current directory: $(pwd)"
echo "Directory contents:"
ls -la

# Ensure logs directory exists (don't try to chmod if we don't own it)
mkdir -p /app/logs 2>/dev/null || true

echo "Logs directory permissions:"
ls -la /app/logs

# Check for available agents and configure instrumentation
JAVA_OPTS=""
if [ -f "/app/downloaded-agents/appdynamics-agent/javaagent.jar" ]; then
    echo "✅ AppDynamics agent found - enabling AppDynamics instrumentation"
    JAVA_OPTS="-javaagent:/app/downloaded-agents/appdynamics-agent/javaagent.jar"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.agent.applicationName=${APPD_APP_NAME:-LogObserverConnectEISDemo2}"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.agent.tierName=${APPD_TIER_NAME:-WebTier}"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.agent.nodeName=${APPD_NODE_NAME:-WebNode}"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.controller.hostName=${APPD_CONTROLLER_HOST:-controller.example.com}"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.controller.port=${APPD_CONTROLLER_PORT:-443}"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.controller.ssl.enabled=${APPD_SSL_ENABLED:-true}"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.agent.accountName=${APPD_ACCOUNT_NAME:-your-account}"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.agent.accountAccessKey=${APPD_ACCESS_KEY:-your-access-key}"
elif [ -f "/app/appdynamics-agent/javaagent.jar" ]; then
    echo "✅ AppDynamics agent found (legacy location) - enabling AppDynamics instrumentation"
    JAVA_OPTS="-javaagent:/app/appdynamics-agent/javaagent.jar"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.agent.applicationName=${APPD_APP_NAME:-LogObserverConnectEISDemo2}"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.agent.tierName=${APPD_TIER_NAME:-WebTier}"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.agent.nodeName=${APPD_NODE_NAME:-WebNode}"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.controller.hostName=${APPD_CONTROLLER_HOST:-controller.example.com}"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.controller.port=${APPD_CONTROLLER_PORT:-443}"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.controller.ssl.enabled=${APPD_SSL_ENABLED:-true}"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.agent.accountName=${APPD_ACCOUNT_NAME:-your-account}"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.agent.accountAccessKey=${APPD_ACCESS_KEY:-your-access-key}"
elif [ -f "/app/downloaded-agents/splunk-otel/splunk-otel-javaagent.jar" ]; then
    echo "✅ Splunk OpenTelemetry agent found - enabling OpenTelemetry instrumentation"
    JAVA_OPTS="-javaagent:/app/downloaded-agents/splunk-otel/splunk-otel-javaagent.jar"
    JAVA_OPTS="$JAVA_OPTS -Dotel.resource.attributes=service.name=${OTEL_SERVICE_NAME:-spring-petclinic}"
    JAVA_OPTS="$JAVA_OPTS -Dotel.exporter.otlp.endpoint=${OTEL_EXPORTER_OTLP_ENDPOINT:-http://localhost:4318}"
    JAVA_OPTS="$JAVA_OPTS -Dsplunk.profiler.enabled=${SPLUNK_PROFILER_ENABLED:-false}"
    JAVA_OPTS="$JAVA_OPTS -Dsplunk.metrics.enabled=${SPLUNK_METRICS_ENABLED:-true}"
else
    echo "⚠️  No observability agents found - running without instrumentation"
    echo "   Available agents: AppDynamics, Splunk OpenTelemetry"
    echo "   To add agents: run download-agents.sh before docker build or mount as volume"
fi

# Execute the Java application
exec java $JAVA_OPTS -jar app.jar