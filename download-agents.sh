#!/bin/bash
# Script to download and set up agents for the PetClinic demo

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$SCRIPT_DIR/downloaded-agents"

echo "🤖 Agent Download and Setup Script"
echo "=================================="

# Create agents directory
mkdir -p "$AGENTS_DIR"

download_appd_agent() {
    echo "📥 Downloading AppDynamics Java Agent..."
    
    # Create AppDynamics directory
    mkdir -p "$AGENTS_DIR/appdynamics-agent"
    
    # Download latest AppDynamics Java Agent
    APPD_VERSION="25.7.0.37201"  # Update this to latest version
    APPD_URL="https://download.appdynamics.com/download/prox/download-file/sun-jvm/${APPD_VERSION}/AppDynamicsJavaAgent-${APPD_VERSION}.zip"
    
    echo "Downloading from: $APPD_URL"
    echo "Note: This requires an AppDynamics account. If download fails, please:"
    echo "1. Visit https://download.appdynamics.com/download/"
    echo "2. Login with your AppDynamics credentials"
    echo "3. Download the Java Agent manually"
    echo "4. Extract it to: $AGENTS_DIR/appdynamics-agent/"
    
    # Try to download (may require authentication)
    if curl -L -o "$AGENTS_DIR/appd-agent.zip" "$APPD_URL" 2>/dev/null; then
        # Check if we got a real ZIP file (not an HTML login page)
        if file "$AGENTS_DIR/appd-agent.zip" | grep -q "Zip archive"; then
            cd "$AGENTS_DIR"
            if unzip -q appd-agent.zip -d appdynamics-agent/ 2>/dev/null; then
                rm appd-agent.zip
                echo "✅ AppDynamics Agent downloaded and extracted"
                return 0
            fi
        fi
        # Clean up failed download
        rm -f "$AGENTS_DIR/appd-agent.zip"
    fi
    
    echo "❌ Automatic download failed - authentication required"
    echo ""
    echo "🔐 AppDynamics requires account authentication for downloads"
    echo "📋 Manual download instructions:"
    echo "   1. Visit: https://download.appdynamics.com/download/"
    echo "   2. Login with your AppDynamics credentials"
    echo "   3. Search for 'Java Agent' or navigate to Java section"
    echo "   4. Download 'AppDynamicsJavaAgent-${APPD_VERSION}.zip'"
    echo "   5. Extract contents to: $AGENTS_DIR/appdynamics-agent/"
    echo ""
    echo "💡 Alternative: Use Splunk OpenTelemetry agent (no auth required)"
    return 1
}

download_splunk_otel_agent() {
    echo "📥 Downloading Splunk OpenTelemetry Java Agent..."
    
    mkdir -p "$AGENTS_DIR/splunk-otel"
    
    # Get latest release info from GitHub API
    LATEST_RELEASE=$(curl -s https://api.github.com/repos/signalfx/splunk-otel-java/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    
    echo "Latest Splunk OTEL Java Agent version: $LATEST_RELEASE"
    
    # Use the correct filename from GitHub releases (no version suffix)
    OTEL_URL="https://github.com/signalfx/splunk-otel-java/releases/download/${LATEST_RELEASE}/splunk-otel-javaagent.jar"
    
    if curl -L -o "$AGENTS_DIR/splunk-otel/splunk-otel-javaagent.jar" "$OTEL_URL"; then
        # Verify the download was successful (not just "Not Found")
        if [ -s "$AGENTS_DIR/splunk-otel/splunk-otel-javaagent.jar" ] && [ $(wc -c < "$AGENTS_DIR/splunk-otel/splunk-otel-javaagent.jar") -gt 1000 ]; then
            echo "✅ Splunk OpenTelemetry Java Agent downloaded successfully!"
            echo "📊 File size: $(ls -lh "$AGENTS_DIR/splunk-otel/splunk-otel-javaagent.jar" | awk '{print $5}')"
        else
            echo "❌ Download failed - received invalid file"
            rm -f "$AGENTS_DIR/splunk-otel/splunk-otel-javaagent.jar"
            return 1
        fi
    else
        echo "❌ Failed to download Splunk OpenTelemetry Java Agent"
        return 1
    fi
}

download_elastic_apm_agent() {
    echo "📥 Downloading Elastic APM Java Agent..."
    
    mkdir -p "$AGENTS_DIR/elastic-apm"
    
    # Get latest release info
    ELASTIC_VERSION=$(curl -s https://api.github.com/repos/elastic/apm-agent-java/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    ELASTIC_VERSION=${ELASTIC_VERSION#v}  # Remove 'v' prefix if present
    
    echo "Latest Elastic APM Java Agent version: $ELASTIC_VERSION"
    
    ELASTIC_URL="https://repo1.maven.org/maven2/co/elastic/apm/elastic-apm-agent/${ELASTIC_VERSION}/elastic-apm-agent-${ELASTIC_VERSION}.jar"
    
    if curl -L -o "$AGENTS_DIR/elastic-apm/elastic-apm-agent-${ELASTIC_VERSION}.jar" "$ELASTIC_URL"; then
        echo "✅ Elastic APM Java Agent downloaded"
        
        # Create a symlink for easier reference
        ln -sf "elastic-apm-agent-${ELASTIC_VERSION}.jar" "$AGENTS_DIR/elastic-apm/elastic-apm-agent.jar"
    else
        echo "❌ Failed to download Elastic APM Java Agent"
        return 1
    fi
}

# Create configuration templates for different agents
create_agent_configs() {
    echo "📝 Creating agent configuration templates..."
    
    # AppDynamics entrypoint
    cat > "$AGENTS_DIR/appdynamics-entrypoint.sh" << 'EOF'
#!/bin/sh
# AppDynamics-specific entrypoint

set -e

# Build JAVA_OPTS for AppDynamics
JAVA_OPTS="-javaagent:/app/downloaded-agents/appdynamics-agent/javaagent.jar \
-Dappdynamics.controller.hostName=${APPD_CONTROLLER_HOST} \
-Dappdynamics.controller.port=${APPD_CONTROLLER_PORT} \
-Dappdynamics.controller.ssl.enabled=${APPD_SSL} \
-Dappdynamics.agent.accountName=${APPD_ACCOUNT_NAME} \
-Dappdynamics.agent.accountAccessKey=${APPD_KEY} \
-Dappdynamics.agent.applicationName=${APPD_APP_NAME:-PetClinicDemo} \
-Dappdynamics.agent.tierName=${APPD_TIER_NAME:-WebTier} \
-Dappdynamics.agent.nodeName=${APPD_NODE_NAME:-WebNode}"

export JAVA_OPTS

mkdir -p /app/logs
chmod 777 /app/logs

exec java $JAVA_OPTS -jar /app/app.jar
EOF

    # Splunk OTEL entrypoint
    cat > "$AGENTS_DIR/splunk-otel-entrypoint.sh" << 'EOF'
#!/bin/sh
# Splunk OpenTelemetry-specific entrypoint

set -e

# Build JAVA_OPTS for Splunk OTEL
JAVA_OPTS="-javaagent:/app/downloaded-agents/splunk-otel/splunk-otel-javaagent.jar \
-Dsplunk.access.token=${SPLUNK_ACCESS_TOKEN} \
-Dsplunk.realm=${SPLUNK_REALM} \
-Dotel.service.name=${OTEL_SERVICE_NAME:-petclinic} \
-Dotel.resource.attributes=deployment.environment=${OTEL_ENVIRONMENT:-development}"

export JAVA_OPTS

mkdir -p /app/logs
chmod 777 /app/logs

exec java $JAVA_OPTS -jar /app/app.jar
EOF

    # Elastic APM entrypoint
    cat > "$AGENTS_DIR/elastic-apm-entrypoint.sh" << 'EOF'
#!/bin/sh
# Elastic APM-specific entrypoint

set -e

# Build JAVA_OPTS for Elastic APM
JAVA_OPTS="-javaagent:/app/downloaded-agents/elastic-apm/elastic-apm-agent.jar \
-Delastic.apm.server_urls=${ELASTIC_APM_SERVER_URL} \
-Delastic.apm.secret_token=${ELASTIC_APM_SECRET_TOKEN} \
-Delastic.apm.service_name=${ELASTIC_APM_SERVICE_NAME:-petclinic} \
-Delastic.apm.environment=${ELASTIC_APM_ENVIRONMENT:-development}"

export JAVA_OPTS

mkdir -p /app/logs
chmod 777 /app/logs

exec java $JAVA_OPTS -jar /app/app.jar
EOF

    # Make scripts executable
    chmod +x "$AGENTS_DIR"/*-entrypoint.sh
    
    echo "✅ Agent configuration templates created"
}

# Main execution
echo "Select which agents to download:"
echo "1) AppDynamics Java Agent"
echo "2) Splunk OpenTelemetry Java Agent" 
echo "3) Elastic APM Java Agent"
echo "4) All agents"
echo "5) Skip download (just create config templates)"

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        download_appd_agent
        ;;
    2)
        download_splunk_otel_agent
        ;;
    3)
        download_elastic_apm_agent
        ;;
    4)
        download_appd_agent || echo "⚠️  AppDynamics download failed, continuing..."
        download_splunk_otel_agent || echo "⚠️  Splunk OTEL download failed, continuing..."
        download_elastic_apm_agent || echo "⚠️  Elastic APM download failed, continuing..."
        ;;
    5)
        echo "Skipping downloads..."
        ;;
    *)
        echo "Invalid choice, skipping downloads..."
        ;;
esac

create_agent_configs

echo ""
echo "✅ Agent setup complete!"
echo ""
echo "📁 Downloaded agents are in: $AGENTS_DIR"
echo ""
echo "🔧 To use a different agent:"
echo "1. Update docker-compose.yml to mount the appropriate agent directory"
echo "2. Update the entrypoint to use the corresponding agent entrypoint script"
echo "3. Update secrets.env with the appropriate configuration"