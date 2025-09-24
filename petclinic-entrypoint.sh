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

# Execute the Java application
exec java \
    -javaagent:/app/appdynamics-agent/javaagent.jar \
    -Dappdynamics.agent.applicationName=${APPD_APP_NAME:-LogObserverConnectEISDemo2} \
    -Dappdynamics.agent.tierName=${APPD_TIER_NAME:-WebTier} \
    -Dappdynamics.agent.nodeName=${APPD_NODE_NAME:-WebNode} \
    -Dappdynamics.controller.hostName=${APPD_CONTROLLER_HOST:-controller.example.com} \
    -Dappdynamics.controller.port=${APPD_CONTROLLER_PORT:-443} \
    -Dappdynamics.controller.ssl.enabled=${APPD_SSL_ENABLED:-true} \
    -Dappdynamics.agent.accountName=${APPD_ACCOUNT_NAME:-your-account} \
    -Dappdynamics.agent.accountAccessKey=${APPD_ACCESS_KEY:-your-access-key} \
    -jar app.jar