@echo off
REM Setup script for Windows

echo 🚀 Setting up Spring PetClinic Log Observer Connect Demo
echo ==================================================

REM Check for Docker
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not installed or not in PATH
    echo    Please install Docker Desktop from: https://docs.docker.com/desktop/windows/
    pause
    exit /b 1
) else (
    echo ✅ Docker is available
)

REM Check for Docker Compose
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Compose is not installed or not in PATH
    echo    Please install Docker Compose from: https://docs.docker.com/compose/install/
    pause
    exit /b 1
) else (
    echo ✅ Docker Compose is available
)

REM Check for Git (optional)
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ℹ️  Git not found (optional for running the demo)
) else (
    echo ✅ Git is available
)

REM Check for Java (optional)
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ℹ️  Java not found locally (OK - we'll use Docker)
) else (
    echo ✅ Java is available locally
)

REM Create secrets.env if it doesn't exist
if not exist "secrets.env" (
    echo.
    echo 📝 Creating secrets.env template...
    (
        echo # Secrets file for Spring Boot PetClinic Log Observer Connect Demo
        echo # IMPORTANT: Fill in your actual values below!
        echo.
        echo # Splunk Configuration
        echo SPLUNK_PASSWORD=changeme_your_splunk_password
        echo SOURCETYPE=SpringBootEIS
        echo INDEX=eislogobserverconnect
        echo CONTROLLER=your.splunk.host:9998
        echo.
        echo # AppDynamics Configuration
        echo APPD_CONTROLLER_HOST=your-controller.saas.appdynamics.com
        echo APPD_ACCOUNT_NAME=your-account-name
        echo APPD_CONTROLLER_PORT=443
        echo APPD_SSL=true
        echo APPD_KEY=your-account-access-key
        echo.
        echo # Database Configuration (if using external DB^)
        echo # POSTGRES_PASSWORD=your_postgres_password
        echo # MYSQL_ROOT_PASSWORD=your_mysql_password
    ) > secrets.env
    echo ✅ Created secrets.env template
    echo ⚠️  IMPORTANT: Edit secrets.env with your actual configuration values!
) else (
    echo ✅ secrets.env already exists
)

echo.
echo 🏗️  Building the application...
docker-compose build --no-cache

echo.
echo ✅ Setup complete!
echo.
echo 📚 Next steps:
echo 1. Edit secrets.env with your actual AppDynamics and Splunk configuration
echo 2. For Splunk configuration, you'll need to manually render templates (see README^)
echo 3. Run: docker-compose up -d
echo 4. Access the application at: http://localhost:8080
echo.
echo 🔧 Troubleshooting:
echo    - View logs: docker-compose logs -f
echo    - Stop services: docker-compose down
echo    - Rebuild: docker-compose build --no-cache
echo.
pause