# Spring PetClinic Log Observer Connect Demo

[![Build Status](https://github.com/spring-projects/spring-petclinic/actions/workflows/maven-build.yml/badge.svg)](https://github.com/spring-projects/spring-petclinic/actions/workflows/maven-build.yml)[![Build Status](https://github.com/spring-projects/spring-petclinic/actions/workflows/gradle-build.yml/badge.svg)](https://github.com/spring-projects/spring-petclinic/actions/workflows/gradle-build.yml)

A demonstration of the Spring PetClinic application integrated with observability tools including AppDynamics and Splunk Universal Forwarder for log forwarding and application monitoring.

## ✨ Features

- 🍎 **Apple Silicon & Intel Mac Support** - Native ARM64 performance where possible
- 🐳 **Docker-First Approach** - Containerized for consistency across environments  
- 🔄 **Multi-Agent Support** - AppDynamics, Splunk OTEL, Elastic APM
- 🏗️ **Flexible Build Systems** - Maven and Gradle support
- 🖥️ **Cross-Platform** - Windows, macOS, Linux compatible
- 🚀 **One-Command Startup** - Intelligent scripts handle setup and launch
- 🔧 **Auto-Detection** - Scripts detect your OS and architecture automatically

## 🚀 Quick Start

### For All Operating Systems

1. **Automated Setup (Recommended)**
   ```bash
   # Unix-like systems (macOS, Linux) - Complete startup
   git clone <your-repo-url>
   cd spring-petclinic-LogObserverConnectDemo
   ./start.sh          # Universal startup - detects your OS automatically
   
   # Mac users - Architecture-optimized startup
   ./start-mac.sh      # Apple Silicon/Intel Mac optimized
   
   # Windows
   git clone <your-repo-url>
   cd spring-petclinic-LogObserverConnectDemo
   setup.bat           # Setup only - then use docker-compose up -d
   ```

2. **Step-by-Step Setup**
   ```bash
   # 1. Initial setup and configuration
   ./setup.sh          # Downloads dependencies, creates secrets.env template
   
   # 2. Edit your configuration
   # Edit secrets.env with your AppDynamics, Splunk, etc. settings
   
   # 3. Start the application
   ./start.sh          # Universal startup script
   # OR
   ./start-mac.sh      # Mac-specific optimized startup
   ```

3. **Manual Setup**
   - See [Cross-Platform Setup Guide](./CROSS_PLATFORM_SETUP.md) for detailed instructions for your operating system

### Prerequisites
- Docker Desktop
- Git
- Platform-specific tools (see [Cross-Platform Setup Guide](./CROSS_PLATFORM_SETUP.md))

### 🍎 **Mac Users (Intel & Apple Silicon)**

This project is optimized for both Mac architectures:

#### **Apple Silicon (M1/M2/M3) Macs** ⚡
- ✅ **Native Performance**: Java application runs natively (ARM64)
- ✅ **Better Battery Life**: Optimized for Apple Silicon chips
- ✅ **Auto-Detection**: Setup script automatically configures for your architecture

#### **Intel Macs** 🖥️  
- ✅ **Full Compatibility**: All components run natively
- ✅ **Standard Performance**: Optimal speed across all services

#### **Quick Mac Setup:**
```bash
# Option 1: Mac-Optimized Startup (Recommended)
./start-mac.sh     # One command - handles everything!

# Option 2: Step-by-step setup
./check-architecture.sh  # Check your Mac architecture (optional)
./setup.sh               # Run the optimized setup
./start.sh               # Universal startup script

# Option 3: Traditional approach
docker-compose up -d     # Manual Docker Compose
```

**🚀 New Startup Scripts:**
- **`./start-mac.sh`** - Apple Silicon optimized, handles complete startup
- **`./start.sh`** - Universal startup script for any OS
- **`./setup.sh`** - Initial setup and configuration
- **`./check-architecture.sh`** - Architecture detection and recommendations

**Note**: If you experience any issues on Apple Silicon, see the [Mac Compatibility Guide](./MAC_COMPATIBILITY.md) for troubleshooting steps.

## 🔧 Configuration

### Quick Start (Recommended)
```bash
# One-command startup for most users
./start.sh          # Universal - works on any OS
./start-mac.sh      # Mac-optimized (Apple Silicon/Intel)
```

### Manual Configuration
1. **Edit your secrets:**
   - Copy `secrets.env.example` to `secrets.env` and fill in your values (AppDynamics, Splunk, etc.)

2. **Choose your observability agent:**
   - **Default**: AppDynamics (pre-configured)
   - **Alternative**: Download other agents using `./download-agents.sh`

3. **Build and start:**
   ```bash
   # For Splunk configuration (Unix-like systems)
   ./splunkuf-config/render-and-restart-splunkuf.sh
   
   # Start all services
   docker-compose up -d
   ```

4. **Access the application:**
   - Petclinic: [http://localhost:8080](http://localhost:8080)
   - H2 Console: [http://localhost:8080/h2-console](http://localhost:8080/h2-console)

## 🛠️ Available Scripts

| Script | Purpose | Best For |
|--------|---------|----------|
| `./start.sh` | **Universal startup** - detects OS and optimizes | Any operating system |
| `./start-mac.sh` | **Mac-optimized startup** - Apple Silicon/Intel aware | macOS users (recommended) |
| `./setup.sh` | **Initial setup** - dependencies, configuration templates | First-time setup |
| `./build.sh` | **Universal build** - supports Maven/Gradle, Docker | Building without starting |
| `./check-architecture.sh` | **System detection** - OS, architecture, Docker status | Troubleshooting, info |
| `./download-agents.sh` | **Agent download** - AppDynamics, Splunk OTEL, Elastic APM | Alternative agents |
| `setup.bat` | **Windows setup** - dependency checks and configuration | Windows users |

### Script Usage Examples
```bash
# Complete startup (recommended for most users)
./start.sh

# Mac-specific optimized startup
./start-mac.sh

# Just setup, no startup
./setup.sh

# Check your system compatibility
./check-architecture.sh

# Download alternative observability agents
./download-agents.sh

# Build only (no startup)
./build.sh
```

<img width="1042" alt="petclinic-screenshot" src="https://cloud.githubusercontent.com/assets/838318/19727082/2aee6d6c-9b8e-11e6-81fe-e889a5ddfded.png">

## In case you find a bug/suggested improvement for Spring Petclinic

Our issue tracker is available [here](https://github.com/spring-projects/spring-petclinic/issues).


## Database Configuration

By default, Petclinic uses an in-memory H2 database, which is auto-populated at startup. The H2 console is available at [http://localhost:8080/h2-console](http://localhost:8080/h2-console). The JDBC URL is printed in the logs at startup.

To use MySQL or PostgreSQL instead:
- Uncomment the relevant service in `docker-compose.yml`.
- Set `SPRING_PROFILES_ACTIVE=mysql` or `SPRING_PROFILES_ACTIVE=postgres` in the Petclinic service environment.
- Provide the necessary secrets in `secrets.env`.

See the [Spring Boot documentation](https://docs.spring.io/spring-boot/how-to/properties-and-configuration.html#howto.properties-and-configuration.set-active-spring-profiles) for more details.

## Test Applications

At development time we recommend you use the test applications set up as `main()` methods in `PetClinicIntegrationTests` (using the default H2 database and also adding Spring Boot Devtools), `MySqlTestApplication` and `PostgresIntegrationTests`. These are set up so that you can run the apps in your IDE to get fast feedback and also run the same classes as integration tests against the respective database. The MySql integration tests use Testcontainers to start the database in a Docker container, and the Postgres tests use Docker Compose to do the same thing.

## Compiling the CSS

There is a `petclinic.css` in `src/main/resources/static/resources/css`. It was generated from the `petclinic.scss` source, combined with the [Bootstrap](https://getbootstrap.com/) library. If you make changes to the `scss`, or upgrade Bootstrap, you will need to re-compile the CSS resources using the Maven profile "css", i.e. `./mvnw package -P css`. There is no build profile for Gradle to compile the CSS.

## Working with Petclinic in your IDE

### Prerequisites

The following items should be installed in your system:

- Java 17 or newer (full JDK, not a JRE)
- [Git command line tool](https://help.github.com/articles/set-up-git)
- Your preferred IDE
  - Eclipse with the m2e plugin. Note: when m2e is available, there is an m2 icon in `Help -> About` dialog. If m2e is
  not there, follow the install process [here](https://www.eclipse.org/m2e/)
  - [Spring Tools Suite](https://spring.io/tools) (STS)
  - [IntelliJ IDEA](https://www.jetbrains.com/idea/)
  - [VS Code](https://code.visualstudio.com)

### Steps

1. On the command line run:

    ```bash
    git clone https://github.com/spring-projects/spring-petclinic.git
    ```

1. Inside Eclipse or STS:

    Open the project via `File -> Import -> Maven -> Existing Maven project`, then select the root directory of the cloned repo.

    Then either build on the command line `./mvnw generate-resources` or use the Eclipse launcher (right-click on project and `Run As -> Maven install`) to generate the CSS. Run the application's main method by right-clicking on it and choosing `Run As -> Java Application`.

1. Inside IntelliJ IDEA:

    In the main menu, choose `File -> Open` and select the Petclinic [pom.xml](pom.xml). Click on the `Open` button.

    - CSS files are generated from the Maven build. You can build them on the command line `./mvnw generate-resources` or right-click on the `spring-petclinic` project then `Maven -> Generates sources and Update Folders`.

    - A run configuration named `PetClinicApplication` should have been created for you if you're using a recent Ultimate version. Otherwise, run the application by right-clicking on the `PetClinicApplication` main class and choosing `Run 'PetClinicApplication'`.

1. Navigate to the Petclinic

    Visit [http://localhost:8080](http://localhost:8080) in your browser.

## Looking for something in particular?

|Spring Boot Configuration | Class or Java property files  |
|--------------------------|---|
|The Main Class | [PetClinicApplication](https://github.com/spring-projects/spring-petclinic/blob/main/src/main/java/org/springframework/samples/petclinic/PetClinicApplication.java) |
|Properties Files | [application.properties](https://github.com/spring-projects/spring-petclinic/blob/main/src/main/resources) |
|Caching | [CacheConfiguration](https://github.com/spring-projects/spring-petclinic/blob/main/src/main/java/org/springframework/samples/petclinic/system/CacheConfiguration.java) |

## Interesting Spring Petclinic branches and forks

The Spring Petclinic "main" branch in the [spring-projects](https://github.com/spring-projects/spring-petclinic)
GitHub org is the "canonical" implementation based on Spring Boot and Thymeleaf. There are
[quite a few forks](https://spring-petclinic.github.io/docs/forks.html) in the GitHub org
[spring-petclinic](https://github.com/spring-petclinic). If you are interested in using a different technology stack to implement the Pet Clinic, please join the community there.

## Interaction with other open-source projects

One of the best parts about working on the Spring Petclinic application is that we have the opportunity to work in direct contact with many Open Source projects. We found bugs/suggested improvements on various topics such as Spring, Spring Data, Bean Validation and even Eclipse! In many cases, they've been fixed/implemented in just a few days.
Here is a list of them:

| Name | Issue |
|------|-------|
| Spring JDBC: simplify usage of NamedParameterJdbcTemplate | [SPR-10256](https://github.com/spring-projects/spring-framework/issues/14889) and [SPR-10257](https://github.com/spring-projects/spring-framework/issues/14890) |
| Bean Validation / Hibernate Validator: simplify Maven dependencies and backward compatibility |[HV-790](https://hibernate.atlassian.net/browse/HV-790) and [HV-792](https://hibernate.atlassian.net/browse/HV-792) |
| Spring Data: provide more flexibility when working with JPQL queries | [DATAJPA-292](https://github.com/spring-projects/spring-data-jpa/issues/704) |

## Contributing

The [issue tracker](https://github.com/spring-projects/spring-petclinic/issues) is the preferred channel for bug reports, feature requests and submitting pull requests.

For pull requests, editor preferences are available in the [editor config](.editorconfig) for easy use in common text editors. Read more and download plugins at <https://editorconfig.org>. All commits must include a __Signed-off-by__ trailer at the end of each commit message to indicate that the contributor agrees to the Developer Certificate of Origin.
For additional details, please refer to the blog post [Hello DCO, Goodbye CLA: Simplifying Contributions to Spring](https://spring.io/blog/2025/01/06/hello-dco-goodbye-cla-simplifying-contributions-to-spring).

## License

The Spring PetClinic sample application is released under version 2.0 of the [Apache License](https://www.apache.org/licenses/LICENSE-2.0).

## 🛠️ Mac Architecture Support

### Performance Optimization by Chip Type

| Component | Intel Mac | Apple Silicon Mac | Notes |
|-----------|-----------|-------------------|-------|
| **Java Application** | ✅ Native | ✅ **Native** | Eclipse Temurin supports ARM64 |
| **PostgreSQL** | ✅ Native | ✅ **Native** | Full ARM64 support |
| **Splunk UF** | ✅ Native | ⚡ Emulated | Rosetta 2 (good performance) |
| **JMeter** | ✅ Native | ⚡ Emulated | Rosetta 2 (good performance) |

### Architecture-Specific Commands

```bash
# Check your Mac's architecture
./check-architecture.sh

# Apple Silicon troubleshooting (if needed)
export DOCKER_DEFAULT_PLATFORM=linux/amd64  # Force compatibility
docker-compose build --no-cache
docker-compose up -d

# Reset to native architecture
unset DOCKER_DEFAULT_PLATFORM
docker-compose build --no-cache
```

### Additional Resources
- [Mac Compatibility Guide](./MAC_COMPATIBILITY.md) - Detailed Apple Silicon vs Intel information
- [Cross-Platform Setup Guide](./CROSS_PLATFORM_SETUP.md) - OS-specific installation instructions

## 📁 Key Files

| File | Description |
|------|-------------|
| `secrets.env` | **Your configuration** - AppDynamics, Splunk settings (create from template) |
| `secrets.env.example` | **Configuration template** - Copy this to `secrets.env` |
| `docker-compose.yml` | **Service definitions** - All containers and networking |
| `Dockerfile` | **Application container** - Multi-stage build with security features |
| `MAC_COMPATIBILITY.md` | **Mac guide** - Apple Silicon vs Intel detailed comparison |
| `CROSS_PLATFORM_SETUP.md` | **Setup guide** - OS-specific instructions and troubleshooting |

## 🚀 Quick Commands Reference

```bash
# Complete startup (recommended)
./start.sh               # Universal - any OS
./start-mac.sh          # Mac-optimized

# Setup only
./setup.sh              # Initial setup and dependencies

# Information and diagnostics  
./check-architecture.sh # System info and recommendations
docker-compose ps       # Service status
docker-compose logs -f  # Live logs

# Management
docker-compose down     # Stop all services
docker-compose restart  # Restart services
./build.sh              # Build without starting
```


## AppDynamics and Splunk Universal Forwarder

### AppDynamics Java Agent
- The AppDynamics agent is attached automatically at runtime.
- All controller and authentication settings are injected from `secrets.env` via system properties.
- No sensitive values are committed to the repository.

### Splunk Universal Forwarder
- Before running `docker-compose up`, render the Splunk config files and restart the UF container:
    ```bash
    ./splunkuf-config/render-and-restart-splunkuf.sh
    ```
- This script uses `envsubst` and your `secrets.env` to generate config files in `splunkuf-config/rendered/` and restarts the Splunk UF container with a custom entrypoint to bypass Ansible provisioning.
- The rendered directory is mounted into the Splunk UF container.
- You must have `envsubst` (from `gettext`) installed on your host.

**Workflow:**
1. Edit your secrets in `secrets.env` as needed.
2. Run `./splunkuf-config/render-and-restart-splunkuf.sh` to render config files and restart UF.
3. Run `docker-compose up` for the rest of the stack as usual.

## 🚨 Troubleshooting

### Common Issues

**Quick Diagnosis:**
```bash
./check-architecture.sh  # Check system compatibility and Docker status
docker-compose ps        # Check service status
docker-compose logs -f   # View real-time logs
```

**Docker Permission Issues (Linux/Mac):**
```bash
sudo usermod -aG docker $USER  # Add user to docker group
newgrp docker                  # Apply changes
```

**Port 8080 Already in Use:**
```bash
# Find what's using the port
lsof -i :8080
# Or change the port in docker-compose.yml
```

**Build Issues:**
```bash
# Use the build script for automatic detection
./build.sh

# Or clean Docker cache and rebuild manually
docker system prune -a
docker-compose build --no-cache
```

**Complete Reset:**
```bash
# Stop everything and start fresh
docker-compose down
docker system prune -a  # Warning: removes all unused Docker data
./start.sh               # Fresh startup
```

### Mac-Specific Issues

**Apple Silicon Performance:**
```bash
# Check your architecture and get recommendations
./check-architecture.sh

# Use Mac-optimized startup
./start-mac.sh

# If services are slow, ensure native ARM64 when possible
./start.sh  # Universal script handles architecture optimization

# For compatibility issues, force AMD64 emulation
export DOCKER_DEFAULT_PLATFORM=linux/amd64
./start.sh  # or docker-compose build --no-cache
```

**envsubst Command Not Found (macOS):**
```bash
brew install gettext
brew link --force gettext
```
