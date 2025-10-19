# Maven NAR + CMake Hybrid Proof of Concept

Demonstration of using Maven NAR for dependency management with a CMake build system for fast development cycles.

## Features

- ✅ Custom Nexus Docker image with pre-populated Boost NAR artifacts
- ✅ Multi-module Maven project (calculator library + app executable)
- ✅ CMake build configuration auto-generated from Maven dependencies
- ✅ VS Code devcontainer setup with Nexus integration

## Architecture

### Maven NAR Workflow
1. Maven downloads and extracts NAR dependencies (headers + libraries) once
2. Slow validation and build process but reliable dependency management

### CMake Hybrid Workflow
1. Run Maven once to download dependencies: `mvn compile`
2. Generate CMakeLists.txt from extracted dependencies: `./generate-cmake.sh`
3. Fast incremental builds with CMake: `cmake --build build`

## Quick Start

### 1. Build and Start Nexus

```bash
# Build Nexus image with Boost NAR artifacts pre-loaded
docker compose build nexus

# Start Nexus
docker compose up -d nexus

# Check Nexus is healthy (wait for healthy status)
docker compose ps
```

The Nexus build will:
- Accept EULA automatically
- Create `maven-nar-releases` repository
- Clone and build boost-nar (org.boost:* artifacts version 1.57.0+nar.10)
- Deploy ~40 Boost modules to Nexus

### 2. Open in VS Code Dev Container

```bash
# Open project in VS Code
code .

# Command Palette (Ctrl+Shift+P): "Dev Containers: Reopen in Container"
```

The devcontainer will:
- Start the Nexus service automatically
- Configure Maven to use Nexus via settings.xml
- Provide all build tools (Maven, CMake, GCC)

### 3. Build with Maven NAR

Inside the dev container:

```bash
# Build all modules
mvn clean compile

# Run the app
LD_LIBRARY_PATH=app/target/nar/system-1.57.0+nar.10-amd64-Linux-gpp-shared/lib/amd64-Linux-gpp/shared \
  app/target/nar/app-1.0-SNAPSHOT-amd64-Linux-gpp-executable/bin/amd64-Linux-gpp/app
```

### 4. Build with CMake (Fast Development)

```bash
# Generate CMakeLists.txt from Maven NAR dependencies
./generate-cmake.sh

# Build with CMake
cmake -B build
cmake --build build

# Run
build/maven-cmake-poc
```

## Project Structure

```
maven-cmake-poc/
├── pom.xml                      # Parent POM (multi-module coordinator)
├── calculator/                  # Calculator library module
│   ├── pom.xml                  # Builds as shared library NAR
│   └── src/main/
│       ├── c++/calculator.cpp
│       └── include/calculator.h
├── app/                         # Application module
│   ├── pom.xml                  # Depends on calculator + Boost
│   └── src/main/c++/main.cpp
├── nexus/                       # Custom Nexus image
│   ├── Dockerfile
│   └── populate-nexus.sh        # Builds and deploys boost-nar
├── .devcontainer/               # VS Code devcontainer config
│   ├── devcontainer.json
│   ├── Dockerfile
│   └── settings.xml             # Maven config for Nexus
├── generate-cmake.sh            # Auto-generates CMakeLists.txt
└── docker-compose.yml           # Nexus + dev services
```

## Dependencies

From Nexus (maven-nar-releases repository):

- **org.boost:core:1.57.0+nar.10** - Boost.Core (header-only)
- **org.boost:config:1.57.0+nar.10** - Boost.Config (header-only)
- **org.boost:system:1.57.0+nar.10** - Boost.System (compiled library)

Plus 37 more Boost modules available in Nexus (filesystem, regex, asio, etc.)

## How It Works

### Maven NAR Phase
1. Maven resolves NAR dependencies from Nexus
2. NAR plugin extracts to `{module}/target/nar/{artifact}/`
   - Headers: `include/`
   - Libraries: `lib/{arch}/{type}/`
3. NAR plugin compiles and links (slow, lots of validation)

### CMake Hybrid Phase
1. `generate-cmake.sh` scans all `*/target/nar` directories
2. Generates CMakeLists.txt with:
   - All include paths from extracted NARs
   - All library paths from extracted NARs
   - Library link directives
   - Source file lists from both modules
3. CMake builds directly from Maven-extracted dependencies
4. RPATH configured for runtime library loading

## Benefits

- **Dependency Management**: Maven NAR handles complex dependency resolution
- **Fast Builds**: CMake for quick development iterations
- **Repository**: Nexus provides centralized artifact storage
- **Reproducible**: Docker containers ensure consistent environment
- **Multi-module**: Demonstrates library + app structure

## Next Steps

- [x] Multi-module Maven project structure
- [x] Nexus with pre-populated Boost NAR artifacts
- [x] CMake build generation from Maven dependencies
- [ ] Add GTest to Nexus for unit testing
- [ ] Build time comparison benchmarks
