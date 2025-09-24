#!/bin/bash
# Architecture detection and compatibility script

echo "🔍 System Architecture Detection"
echo "================================"

# Detect OS and Architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

case "${OS}" in
    Darwin*)    
        if [[ "$ARCH" == "arm64" ]]; then
            SYSTEM="macOS Apple Silicon (M1/M2/M3)"
            CHIP_TYPE="Apple Silicon"
        else
            SYSTEM="macOS Intel"
            CHIP_TYPE="Intel"
        fi
        ;;
    Linux*)     
        SYSTEM="Linux"
        CHIP_TYPE="$ARCH"
        ;;
    CYGWIN*|MINGW*)    
        SYSTEM="Windows"
        CHIP_TYPE="$ARCH"
        ;;
    *)          
        SYSTEM="Unknown OS: ${OS}"
        CHIP_TYPE="$ARCH"
        ;;
esac

echo "Operating System: $SYSTEM"
echo "Architecture: $ARCH"
echo "Chip Type: $CHIP_TYPE"

# Docker platform recommendations
echo ""
echo "🐳 Docker Platform Recommendations:"
if [[ "$OS" == "Darwin" ]] && [[ "$ARCH" == "arm64" ]]; then
    echo "✅ For best performance: Let Docker choose native ARM64 images when available"
    echo "⚠️  For compatibility: Use 'export DOCKER_DEFAULT_PLATFORM=linux/amd64' if needed"
    echo "📊 Java apps: Will run natively (fast performance)"
    echo "🔧 Third-party services: May use emulation (slightly slower but functional)"
elif [[ "$OS" == "Darwin" ]] && [[ "$ARCH" == "x86_64" ]]; then
    echo "✅ Full compatibility: All Linux AMD64 images will run natively"
    echo "📊 Optimal performance with standard Docker images"
else
    echo "✅ Standard Linux containers should work without issues"
fi

# Check Docker
echo ""
echo "🔧 Docker Environment Check:"
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo "✅ Docker: $DOCKER_VERSION"
    
    # Check if Docker is running
    if docker info >/dev/null 2>&1; then
        echo "✅ Docker daemon: Running"
        
        # Show current default platform
        if [[ -n "$DOCKER_DEFAULT_PLATFORM" ]]; then
            echo "🔧 Default platform override: $DOCKER_DEFAULT_PLATFORM"
        else
            echo "🔧 Default platform: Native ($ARCH)"
        fi
    else
        echo "❌ Docker daemon: Not running (please start Docker Desktop)"
    fi
else
    echo "❌ Docker: Not installed"
fi

# Architecture-specific tips
echo ""
echo "💡 Architecture-Specific Tips:"
if [[ "$OS" == "Darwin" ]] && [[ "$ARCH" == "arm64" ]]; then
    echo "Apple Silicon Mac Tips:"
    echo "• Use './setup.sh' - it's optimized for your architecture"
    echo "• Native ARM64 containers = faster performance + better battery"
    echo "• If compatibility issues occur: 'export DOCKER_DEFAULT_PLATFORM=linux/amd64'"
    echo "• Reset to native: 'unset DOCKER_DEFAULT_PLATFORM'"
elif [[ "$OS" == "Darwin" ]] && [[ "$ARCH" == "x86_64" ]]; then
    echo "Intel Mac Tips:"
    echo "• Full compatibility with all Linux AMD64 images"
    echo "• No special configuration needed"
    echo "• Use './setup.sh' for automated setup"
else
    echo "Linux/Windows Tips:"
    echo "• Use './setup.sh' (Linux) or 'setup.bat' (Windows)"
    echo "• Standard Docker configuration should work well"
fi