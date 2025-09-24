#!/bin/bash
# Optimized startup script for Apple Silicon Mac
# This script provides the best performance and compatibility for M1/M2/M3 Macs

set -e

echo "🍎 Starting Spring PetClinic on Apple Silicon Mac"
echo "================================================"

# Detect architecture to confirm we're on Apple Silicon
ARCH="$(uname -m)"
if [[ "$ARCH" != "arm64" ]]; then
    echo "⚠️  This script is optimized for Apple Silicon Macs (ARM64)"
    echo "   Your architecture: $ARCH"
    echo "   Consider using './setup.sh' for universal compatibility"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi

# Check if secrets.env exists
if [ ! -f "secrets.env" ]; then
    echo "❌ secrets.env file not found!"
    echo "   Please copy secrets.env.example to secrets.env and configure it:"
    echo "   cp secrets.env.example secrets.env"
    echo "   nano secrets.env  # or your preferred editor"
    exit 1
fi

echo "✅ Pre-flight checks passed"

# Show current Docker platform setting
if [[ -n "$DOCKER_DEFAULT_PLATFORM" ]]; then
    echo "🔧 Docker platform override: $DOCKER_DEFAULT_PLATFORM"
else
    echo "🔧 Docker platform: Native ARM64 (optimal for Apple Silicon)"
fi

echo ""
echo "🏗️  Building Spring Boot application..."

# Build the Java application first
if command -v ./mvnw >/dev/null 2>&1; then
    echo "📦 Building with Maven wrapper..."
    ./mvnw clean package -DskipTests
elif command -v mvn >/dev/null 2>&1; then
    echo "📦 Building with system Maven..."
    mvn clean package -DskipTests
elif command -v ./gradlew >/dev/null 2>&1; then
    echo "📦 Building with Gradle wrapper..."
    ./gradlew build -x test
elif command -v gradle >/dev/null 2>&1; then
    echo "📦 Building with system Gradle..."
    gradle build -x test
else
    echo "❌ No build tool found (Maven or Gradle required)"
    echo "   Please install Maven or Gradle and try again"
    exit 1
fi

echo "✅ Application built successfully!"
echo ""
echo "🐳 Building Docker image (optimized for Apple Silicon)..."

# Build without platform constraints for best Apple Silicon performance
# This allows Docker to use native ARM64 images when available
docker-compose build --no-cache

echo ""
echo "🚀 Starting services..."

# For Splunk configuration (if using Splunk)
if [ -f "./splunkuf-config/render-and-restart-splunkuf.sh" ]; then
    echo "📊 Configuring Splunk Universal Forwarder..."
    ./splunkuf-config/render-and-restart-splunkuf.sh
fi

# Start all services
echo "🐳 Starting Docker services..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check service status
echo "📋 Service Status:"
docker-compose ps

echo ""
echo "🎉 Startup Complete!"
echo ""
echo "📱 Application Access:"
echo "   🌐 PetClinic App:    http://localhost:8080"
echo "   🗄️  H2 Console:      http://localhost:8080/h2-console"
echo "   📊 Health Check:     http://localhost:8080/actuator/health"
echo ""
echo "🔧 Useful Commands:"
echo "   📜 View logs:        docker-compose logs -f"
echo "   🛑 Stop services:    docker-compose down"
echo "   🔄 Restart:          docker-compose restart"
echo "   🧹 Clean rebuild:    docker-compose down && docker-compose build --no-cache && docker-compose up -d"
echo ""
echo "🍎 Apple Silicon Optimized:"
echo "   ✅ Java app running natively (ARM64)"
echo "   ✅ PostgreSQL running natively (ARM64)"  
echo "   ⚡ Other services using efficient emulation when needed"
echo ""
echo "🆘 Troubleshooting:"
echo "   • If performance issues: All components should run well"
echo "   • If compatibility issues: export DOCKER_DEFAULT_PLATFORM=linux/amd64"
echo "   • Architecture check: ./check-architecture.sh"
