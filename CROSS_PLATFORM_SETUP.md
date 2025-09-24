# Cross-Platform Setup Guide

This guide helps you set up the Spring PetClinic Log Observer Connect Demo on different operating systems.

## 📋 Prerequisites by Operating System

### All Operating Systems
- Docker Desktop
- Git

### macOS
```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install docker docker-compose gettext
brew link --force gettext  # For envsubst command

# Verify installations
docker --version
docker-compose --version
envsubst --help
```

#### 🍎 **Apple Silicon (M1/M2/M3) vs Intel Mac Differences**

**Apple Silicon Macs (ARM64):**
- ✅ **Better Performance**: Native ARM64 containers run faster
- ✅ **Better Battery Life**: Less CPU overhead
- ⚠️ **Some Emulation**: Third-party images without ARM64 versions run via emulation
- 📊 **Java Apps**: Eclipse Temurin images work natively on both architectures

**Intel Macs (AMD64):**
- ✅ **Full Compatibility**: All container images work natively
- ✅ **No Emulation Needed**: Direct compatibility with Linux AMD64 images

**Our Configuration:**
- Removed hardcoded `platform: linux/amd64` constraints
- Docker automatically selects the best architecture
- Java application runs natively on both chip types
- Third-party services (Splunk, JMeter) may use emulation on Apple Silicon

**If you experience issues on Apple Silicon:**
```bash
# Force AMD64 emulation for compatibility (slower but more compatible)
export DOCKER_DEFAULT_PLATFORM=linux/amd64
docker-compose build --no-cache

# Or use the Mac-specific override (see troubleshooting section)
docker-compose -f docker-compose.yml -f docker-compose.mac.yml up
```

### Ubuntu/Debian Linux
```bash
# Update package list
sudo apt-get update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER  # Add user to docker group
newgrp docker  # Apply group changes

# Install Docker Compose (if not included with Docker)
sudo apt-get install docker-compose-plugin

# Install gettext for envsubst
sudo apt-get install gettext-base

# Verify installations
docker --version
docker-compose --version
envsubst --help
```

### CentOS/RHEL/Fedora
```bash
# Install Docker
sudo dnf install docker docker-compose

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Install gettext for envsubst
sudo dnf install gettext

# Verify installations
docker --version
docker-compose --version
envsubst --help
```

### Windows
1. **Install Docker Desktop for Windows**
   - Download from: https://docs.docker.com/desktop/windows/
   - Ensure WSL 2 is enabled
   - Restart your computer after installation

2. **Install Git for Windows** (if not already installed)
   - Download from: https://git-scm.com/download/win

3. **Verify installations** (in PowerShell or Command Prompt)
   ```cmd
   docker --version
   docker-compose --version
   git --version
   ```

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)

#### Unix-like Systems (macOS, Linux)
```bash
git clone <your-repo-url>
cd spring-petclinic-LogObserverConnectDemo
chmod +x setup.sh
./setup.sh
```

#### Windows
```cmd
git clone <your-repo-url>
cd spring-petclinic-LogObserverConnectDemo
setup.bat
```

### Option 2: Manual Setup

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd spring-petclinic-LogObserverConnectDemo
   ```

2. **Create and configure secrets.env:**
   ```bash
   # Copy the template and edit with your values
   cp secrets.env.example secrets.env
   # Edit secrets.env with your actual AppDynamics and Splunk configuration
   ```

3. **Build the application:**
   
   **Using Docker (Recommended):**
   ```bash
   docker-compose build --no-cache
   ```
   
   **Using Native Tools:**
   ```bash
   # Make build script executable (Unix-like systems)
   chmod +x build.sh
   ./build.sh
   
   # Or manually with Maven
   ./mvnw clean package
   
   # Or manually with Gradle
   ./gradlew clean bootJar
   ```

4. **Start the services:**
   ```bash
   # For Splunk configuration (Unix-like systems only)
   ./splunkuf-config/render-and-restart-splunkuf.sh
   
   # Start all services
   docker-compose up -d
   ```

## 🔧 Alternative Agent Setup

If you want to use different observability agents or download them yourself:

### Download Additional Agents
```bash
# Make script executable (Unix-like systems)
chmod +x download-agents.sh
./download-agents.sh
```

This script can download:
- AppDynamics Java Agent
- Splunk OpenTelemetry Java Agent
- Elastic APM Java Agent

### Configure Different Agents

1. **AppDynamics** (default configuration)
   - Edit `secrets.env` with your AppDynamics controller details
   - Use the default `petclinic-entrypoint.sh`

2. **Splunk OpenTelemetry**
   - Add to `secrets.env`:
     ```
     SPLUNK_ACCESS_TOKEN=your_token
     SPLUNK_REALM=your_realm
     OTEL_SERVICE_NAME=petclinic
     ```
   - Update docker-compose.yml to use `downloaded-agents/splunk-otel-entrypoint.sh`

3. **Elastic APM**
   - Add to `secrets.env`:
     ```
     ELASTIC_APM_SERVER_URL=your_server_url
     ELASTIC_APM_SECRET_TOKEN=your_secret_token
     ELASTIC_APM_SERVICE_NAME=petclinic
     ```
   - Update docker-compose.yml to use `downloaded-agents/elastic-apm-entrypoint.sh`

## 🌐 Database Options

### Default: H2 In-Memory Database
- No additional setup required
- Data is lost when container stops
- H2 Console: http://localhost:8080/h2-console

### PostgreSQL
1. Uncomment the PostgreSQL service in `docker-compose.yml`
2. Set environment variable: `SPRING_PROFILES_ACTIVE=postgres`
3. Configure credentials in `secrets.env`

### MySQL
1. Add MySQL service to `docker-compose.yml`:
   ```yaml
   mysql:
     image: mysql:8.0
     environment:
       MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
       MYSQL_DATABASE: petclinic
     ports:
       - "3306:3306"
   ```
2. Set environment variable: `SPRING_PROFILES_ACTIVE=mysql`
3. Configure credentials in `secrets.env`

## 🐛 Troubleshooting

### Common Issues

1. **Docker not found / Permission denied**
   - Ensure Docker is installed and running
   - Add your user to the docker group (Linux): `sudo usermod -aG docker $USER`
   - Restart your terminal session

2. **envsubst command not found**
   - macOS: `brew install gettext && brew link --force gettext`
   - Linux: `sudo apt-get install gettext-base` or `sudo dnf install gettext`

3. **Port 8080 already in use**
   - Stop other services using port 8080
   - Or change the port in docker-compose.yml: `"8081:8080"`

4. **Build fails due to dependencies**
   - Clear Docker build cache: `docker system prune -a`
   - Ensure stable internet connection for dependency downloads

5. **Agent not attached / No telemetry data**
   - Verify your secrets.env configuration
   - Check container logs: `docker-compose logs petclinic`
   - Ensure your observability backend is accessible

### Platform-Specific Issues

#### macOS Apple Silicon (M1/M2)
```bash
# Use platform specification for compatibility
docker-compose build --platform linux/amd64 --no-cache
```

#### Advanced: Architecture-Specific Issues
```bash
# Check your Mac's architecture
uname -m  # arm64 = Apple Silicon, x86_64 = Intel

# For Apple Silicon Macs experiencing compatibility issues:
export DOCKER_DEFAULT_PLATFORM=linux/amd64
docker-compose build --no-cache

# Alternative: Use Mac-specific override file
docker-compose -f docker-compose.yml -f docker-compose.mac.yml up -d

# Reset to native architecture
unset DOCKER_DEFAULT_PLATFORM
```

#### Windows WSL2
- Ensure WSL2 is enabled and updated
- Use WSL2 terminal for best Docker performance
- File paths should use forward slashes in scripts

#### Linux SELinux
```bash
# If SELinux blocks Docker volumes
sudo setsebool -P container_use_cgroup_devices on
```

## 📚 Additional Resources

- **Docker Documentation**: https://docs.docker.com/
- **Spring Boot Documentation**: https://spring.io/projects/spring-boot
- **AppDynamics Java Agent**: https://docs.appdynamics.com/appd/25.x/25.7/en/application-monitoring/install-app-server-agents/java-agent
- **Splunk OpenTelemetry**: https://docs.splunk.com/Observability/gdi/get-data-in/application/java/get-started.html
- **Elastic APM Java**: https://www.elastic.co/guide/en/apm/agent/java/current/index.html

## 🤝 Contributing

When contributing to this project, please ensure your changes work across all supported platforms:
- Test on at least one Unix-like system (macOS/Linux)
- Test on Windows (if possible)
- Update this compatibility guide if you add new dependencies
- Use environment variables for configuration rather than hard-coded values