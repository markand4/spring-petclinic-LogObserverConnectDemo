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

# Check if AppDynamics agent is available
JAVA_OPTS=""
if [ -f "/app/appdynamics-agent/javaagent.jar" ]; then
    echo "✅ AppDynamics agent found - enabling instrumentation"
    JAVA_OPTS="-javaagent:/app/appdynamics-agent/javaagent.jar"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.agent.applicationName=${APPD_APP_NAME:-LogObserverConnectEISDemo2}"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.agent.tierName=${APPD_TIER_NAME:-WebTier}"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.agent.nodeName=${APPD_NODE_NAME:-WebNode}"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.controller.hostName=${APPD_CONTROLLER_HOST:-controller.example.com}"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.controller.port=${APPD_CONTROLLER_PORT:-443}"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.controller.ssl.enabled=${APPD_SSL_ENABLED:-true}"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.agent.accountName=${APPD_ACCOUNT_NAME:-your-account}"
    JAVA_OPTS="$JAVA_OPTS -Dappdynamics.agent.accountAccessKey=${APPD_ACCESS_KEY:-your-access-key}"
else
    echo "⚠️  AppDynamics agent not found - running without instrumentation"
    echo "   To add agent: run download-agents.sh before docker build or mount as volume"
fi

# Execute the Java application
exec java $JAVA_OPTS -jar app.jar