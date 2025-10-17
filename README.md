# Maven + Conan Proof of Concept

Comparison of Maven NAR plugin vs Maven+Conan/CMake hybrid approach for C++11 builds targeting RHEL 7.

## Setup

### 1. Build and Start Nexus with Boost NAR artifacts

```bash
# Build the custom Nexus image with boost-nar artifacts pre-loaded
docker-compose build nexus

# Start Nexus
docker-compose up -d nexus

# Wait for Nexus to be ready (check logs)
docker-compose logs -f nexus
```

Note: The Nexus image build will:
- Clone boost-nar repository
- Build boost NAR artifacts
- Deploy them to Nexus's maven-nar-releases repository

### 2. Start the development container

```bash
docker-compose up -d dev
docker-compose exec dev bash
```

### 3. Build the Maven NAR project

Inside the dev container:

```bash
# Test dependency resolution
mvn dependency:tree

# Build the project
mvn clean compile

# Measure build times
time mvn clean compile
time mvn compile  # incremental
```

## Project Structure

```
maven-conan-poc/
├── docker-compose.yml           # Nexus + Dev containers
├── nexus/
│   ├── Dockerfile               # Custom Nexus with boost-nar
│   └── populate-nexus.sh        # Script to populate Nexus
├── pom.xml                      # Maven NAR configuration
└── src/main/
    ├── c++/
    │   ├── calculator.cpp
    │   └── main.cpp
    └── include/
        └── calculator.h
```

## Dependencies

- **boost-system NAR** (from local Nexus): uk.co.froot.maven.nar:boost-system:1.58.0

## Next Steps

- [ ] Measure Maven NAR build times
- [ ] Create Maven+Conan/CMake hybrid version
- [ ] Compare build performance
