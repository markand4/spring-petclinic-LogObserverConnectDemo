#!/bin/bash
# Universal startup script - works on all operating systems
# Automatically detects OS and architecture for optimal configuration

set -e

echo "🚀 Universal PetClinic Startup Script"
echo "===================================="

# Detect OS and Architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

case "${OS}" in
    Darwin*)    
        if [[ "$ARCH" == "arm64" ]]; then
            SYSTEM="macOS Apple Silicon (M1/M2/M3)"
            OPTIMIZATION="native ARM64 performance"
        else
            SYSTEM="macOS Intel"
            OPTIMIZATION="native x86_64 performance"
        fi
        ;;
    Linux*)     
        SYSTEM="Linux"
        OPTIMIZATION="native Linux performance"
        ;;
    CYGWIN*|MINGW*)    
        SYSTEM="Windows"
        OPTIMIZATION="Windows compatibility"
        ;;
    *)          
        SYSTEM="Unknown OS: ${OS}"
        OPTIMIZATION="standard configuration"
        ;;
esac

echo "Detected: $SYSTEM"
echo "Optimization: $OPTIMIZATION"
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker Desktop first."
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi

echo "✅ Docker is available and running"

# Check for secrets.env
if [ ! -f "secrets.env" ]; then
    echo "❌ secrets.env file not found!"
    echo ""
    echo "📝 Setting up configuration:"
    if [ -f "secrets.env.example" ]; then
        cp secrets.env.example secrets.env
        echo "✅ Created secrets.env from template"
        echo "⚠️  Please edit secrets.env with your actual configuration:"
        echo "   - AppDynamics controller details"
        echo "   - Splunk configuration"
        echo "   - Any other required settings"
        echo ""
        read -p "Press Enter to continue after editing secrets.env, or Ctrl+C to exit..."
    else
        echo "   Please create secrets.env with your configuration"
        exit 1
    fi
fi

echo "✅ Configuration file found"

# OS-specific optimizations
echo ""
echo "🔧 Applying OS-specific optimizations..."

if [[ "$OS" == "Darwin" ]] && [[ "$ARCH" == "arm64" ]]; then
    echo "🍎 Apple Silicon optimizations:"
    echo "   • Using native ARM64 containers when available"
    echo "   • Emulation fallback for x86_64-only images"
    if [[ -n "$DOCKER_DEFAULT_PLATFORM" ]]; then
        echo "   • Platform override active: $DOCKER_DEFAULT_PLATFORM"
    fi
elif [[ "$OS" == "Darwin" ]] && [[ "$ARCH" == "x86_64" ]]; then
    echo "🖥️  Intel Mac optimizations:"
    echo "   • Full native x86_64 compatibility"
elif [[ "$OS" == "Linux" ]]; then
    echo "🐧 Linux optimizations:"
    echo "   • Native Linux container performance"
fi

echo ""
echo "🏗️  Building application..."
docker-compose build --no-cache

echo ""
echo "🐳 Starting services..."

# Handle Splunk configuration (Unix-like systems only)
if [[ "$OS" != "CYGWIN"* ]] && [[ "$OS" != "MINGW"* ]]; then
    if [ -f "./splunkuf-config/render-and-restart-splunkuf.sh" ]; then
        echo "📊 Configuring Splunk Universal Forwarder..."
        if command -v envsubst &> /dev/null; then
            ./splunkuf-config/render-and-restart-splunkuf.sh
        else
            echo "⚠️  envsubst not found - skipping Splunk config rendering"
            echo "   Install gettext package for Splunk configuration"
        fi
    fi
fi

# Start all services
docker-compose up -d

echo ""
echo "⏳ Waiting for services to start..."
sleep 15

echo ""
echo "📋 Service Status:"
docker-compose ps

echo ""
echo "🎉 Startup Complete for $SYSTEM!"
echo ""
echo "🌐 Application URLs:"
echo "   • PetClinic:     http://localhost:8080"
echo "   • H2 Console:    http://localhost:8080/h2-console"
echo "   • Health Check:  http://localhost:8080/actuator/health"
echo ""
echo "🔧 Management Commands:"
echo "   • View logs:     docker-compose logs -f"
echo "   • Stop all:      docker-compose down"
echo "   • Restart:       docker-compose restart"
echo "   • Clean rebuild: docker-compose down && docker-compose build --no-cache && docker-compose up -d"
echo ""
echo "🆘 Troubleshooting:"
echo "   • Check status:  docker-compose ps"
echo "   • System info:   ./check-architecture.sh"
if [[ "$OS" == "Darwin" ]] && [[ "$ARCH" == "arm64" ]]; then
    echo "   • Force x86_64:  export DOCKER_DEFAULT_PLATFORM=linux/amd64"
fi