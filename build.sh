#!/bin/bash
# Universal build script that detects and uses the appropriate build system

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🏗️  Universal Java Build Script"
echo "============================="

# Detect build system
if [ -f "pom.xml" ] && [ -f "build.gradle" ]; then
    echo "📁 Both Maven (pom.xml) and Gradle (build.gradle) detected"
    echo "Which build system would you like to use?"
    echo "1) Maven"
    echo "2) Gradle"
    read -p "Enter your choice (1-2): " choice
    case $choice in
        1) BUILD_SYSTEM="maven" ;;
        2) BUILD_SYSTEM="gradle" ;;
        *) echo "Invalid choice, defaulting to Maven"; BUILD_SYSTEM="maven" ;;
    esac
elif [ -f "pom.xml" ]; then
    BUILD_SYSTEM="maven"
    echo "📁 Detected Maven project (pom.xml found)"
elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
    BUILD_SYSTEM="gradle"
    echo "📁 Detected Gradle project (build.gradle found)"
else
    echo "❌ No build system detected (no pom.xml or build.gradle found)"
    exit 1
fi

# Check for Java
check_java() {
    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
        echo "☕ Java version: $JAVA_VERSION"
        if [ "$JAVA_VERSION" -lt 17 ]; then
            echo "⚠️  Java 17+ is recommended for this project"
        fi
        return 0
    else
        echo "❌ Java not found. Please install Java 17+ or use Docker build"
        return 1
    fi
}

# Maven build functions
maven_build() {
    echo "🔨 Building with Maven..."
    
    if [ -f "./mvnw" ]; then
        echo "Using Maven Wrapper (./mvnw)"
        chmod +x ./mvnw
        ./mvnw clean package -DskipTests
    elif command -v mvn &> /dev/null; then
        echo "Using system Maven"
        mvn clean package -DskipTests
    else
        echo "❌ Maven not found. Please install Maven or use Docker build"
        return 1
    fi
}

maven_test() {
    echo "🧪 Running tests with Maven..."
    
    if [ -f "./mvnw" ]; then
        ./mvnw test
    else
        mvn test
    fi
}

# Gradle build functions
gradle_build() {
    echo "🔨 Building with Gradle..."
    
    if [ -f "./gradlew" ]; then
        echo "Using Gradle Wrapper (./gradlew)"
        chmod +x ./gradlew
        ./gradlew clean build -x test
    elif command -v gradle &> /dev/null; then
        echo "Using system Gradle"
        gradle clean build -x test
    else
        echo "❌ Gradle not found. Please install Gradle or use Docker build"
        return 1
    fi
}

gradle_test() {
    echo "🧪 Running tests with Gradle..."
    
    if [ -f "./gradlew" ]; then
        ./gradlew test
    else
        gradle test
    fi
}

# Docker build function
docker_build() {
    echo "🐳 Building with Docker..."
    
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker not found. Please install Docker"
        return 1
    fi
    
    # Build using Docker multi-stage build
    docker build -t petclinic-app .
    echo "✅ Docker image 'petclinic-app' built successfully"
}

# Main build process
echo ""
echo "Build options:"
echo "1) Native build (requires Java and build tools)"
echo "2) Docker build (requires Docker only)"
echo "3) Test only"

read -p "Enter your choice (1-3): " build_choice

case $build_choice in
    1)
        if check_java; then
            if [ "$BUILD_SYSTEM" = "maven" ]; then
                maven_build
            else
                gradle_build
            fi
            echo "✅ Native build completed successfully"
        else
            echo "❌ Native build failed. Consider using Docker build instead."
            exit 1
        fi
        ;;
    2)
        docker_build
        ;;
    3)
        if check_java; then
            if [ "$BUILD_SYSTEM" = "maven" ]; then
                maven_test
            else
                gradle_test
            fi
            echo "✅ Tests completed"
        else
            echo "❌ Cannot run tests without Java"
            exit 1
        fi
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "🎉 Build process completed!"
if [ "$build_choice" = "1" ]; then
    echo "📦 Artifacts location:"
    if [ "$BUILD_SYSTEM" = "maven" ]; then
        echo "   - JAR file: target/spring-petclinic-*.jar"
    else
        echo "   - JAR file: build/libs/spring-petclinic-*.jar"
    fi
fi