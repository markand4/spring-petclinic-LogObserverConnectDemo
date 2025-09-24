#!/bin/bash
# Setup script for Unix-like systems (Linux, macOS)

set -e

echo "🚀 Setting up Spring PetClinic Log Observer Connect Demo"
echo "=================================================="

# Detect OS and Architecture
OS="$(uname -s)"
ARCH="$(uname -m)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    
        MACHINE=Mac
        if [[ "$ARCH" == "arm64" ]]; then
            MACHINE="Mac (Apple Silicon)"
        else
            MACHINE="Mac (Intel)"
        fi
        ;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${OS}"
esac
echo "Detected OS: ${MACHINE}"
echo "Architecture: ${ARCH}"

# Check for required tools
check_dependency() {
    if ! command -v $1 &> /dev/null; then
        echo "❌ $1 is not installed. Please install it first."
        echo "   Installation instructions: $2"
        exit 1
    else
        echo "✅ $1 is available"
    fi
}

echo -e "\n📋 Checking dependencies..."
check_dependency "docker" "https://docs.docker.com/get-docker/"
check_dependency "docker-compose" "https://docs.docker.com/compose/install/"

# Check for gettext (for envsubst)
if [[ "$MACHINE" == "Mac" ]]; then
    if ! command -v envsubst &> /dev/null; then
        echo "❌ envsubst is not available. Installing gettext..."
        if command -v brew &> /dev/null; then
            brew install gettext
            brew link --force gettext
        else
            echo "Please install Homebrew first: https://brew.sh/"
            echo "Then run: brew install gettext && brew link --force gettext"
            exit 1
        fi
    else
        echo "✅ envsubst is available"
    fi
elif [[ "$MACHINE" == "Linux" ]]; then
    if ! command -v envsubst &> /dev/null; then
        echo "❌ envsubst is not available. Please install gettext-base:"
        echo "   Ubuntu/Debian: sudo apt-get install gettext-base"
        echo "   CentOS/RHEL: sudo yum install gettext"
        exit 1
    else
        echo "✅ envsubst is available"
    fi
fi

# Check for Java (optional, since we use Docker)
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
    echo "✅ Java is available: $JAVA_VERSION"
else
    echo "ℹ️  Java not found locally (OK - we'll use Docker)"
fi

# Check for Maven (optional, since we use Docker)
if command -v mvn &> /dev/null; then
    MVN_VERSION=$(mvn -version | head -n 1)
    echo "✅ Maven is available: $MVN_VERSION"
else
    echo "ℹ️  Maven not found locally (OK - we'll use Docker for build)"
fi

# Create secrets.env if it doesn't exist
if [ ! -f "secrets.env" ]; then
    echo -e "\n📝 Creating secrets.env template..."
    cat > secrets.env << 'EOF'
# Secrets file for Spring Boot PetClinic Log Observer Connect Demo
# IMPORTANT: Fill in your actual values below!

# Splunk Configuration
SPLUNK_PASSWORD=changeme_your_splunk_password
SOURCETYPE=SpringBootEIS
INDEX=eislogobserverconnect
CONTROLLER=your.splunk.host:9998

# AppDynamics Configuration
APPD_CONTROLLER_HOST=your-controller.saas.appdynamics.com
APPD_ACCOUNT_NAME=your-account-name
APPD_CONTROLLER_PORT=443
APPD_SSL=true
APPD_KEY=your-account-access-key

# Database Configuration (if using external DB)
# POSTGRES_PASSWORD=your_postgres_password
# MYSQL_ROOT_PASSWORD=your_mysql_password
EOF
    echo "✅ Created secrets.env template"
    echo "⚠️  IMPORTANT: Edit secrets.env with your actual configuration values!"
else
    echo "✅ secrets.env already exists"
fi

# Make scripts executable
echo -e "\n🔧 Making scripts executable..."
chmod +x ./splunkuf-config/render-and-restart-splunkuf.sh 2>/dev/null || echo "⚠️  Could not make render-and-restart-splunkuf.sh executable"
chmod +x ./petclinic-entrypoint.sh 2>/dev/null || echo "⚠️  Could not make petclinic-entrypoint.sh executable"
chmod +x ./setup.sh 2>/dev/null || echo "✅ setup.sh is executable"
chmod +x ./mvnw 2>/dev/null || echo "✅ mvnw is executable"

echo -e "\n🏗️  Building the application..."

# Check if we're on Apple Silicon and need special handling
if [[ "$MACHINE" == "Mac (Apple Silicon)" ]]; then
    echo "🍎 Detected Apple Silicon Mac"
    echo "Building with native ARM64 support for better performance..."
    echo "Note: Some third-party images may fall back to emulation if ARM64 versions aren't available"
    
    # Build without platform specification to use native architecture when possible
    docker-compose build --no-cache
    
    echo ""
    echo "🔧 Apple Silicon Tips:"
    echo "   - Native ARM64 containers will run faster"
    echo "   - Some containers may use emulation (slower but still functional)"
    echo "   - If you encounter issues, you can force AMD64 with:"
    echo "     export DOCKER_DEFAULT_PLATFORM=linux/amd64"
    echo "     docker-compose build --no-cache"
else
    echo "Building application..."
    docker-compose build --no-cache
fi

echo -e "\n✅ Setup complete!"
echo -e "\n📚 Next steps:"
echo "1. Edit secrets.env with your actual AppDynamics and Splunk configuration"
echo "2. Run: ./splunkuf-config/render-and-restart-splunkuf.sh"
echo "3. Run: docker-compose up -d"
echo "4. Access the application at: http://localhost:8080"
echo -e "\n🔧 Troubleshooting:"
echo "   - View logs: docker-compose logs -f"
echo "   - Stop services: docker-compose down"
echo "   - Rebuild: docker-compose build --no-cache"