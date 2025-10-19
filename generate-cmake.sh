#!/bin/bash
set -euo pipefail

# Find all NAR directories in module target directories
NAR_DIRS=$(find . -type d -path "*/target/nar" | sort)

if [ -z "$NAR_DIRS" ]; then
    echo "Error: No target/nar directories found. Run 'mvn compile' first to extract NAR dependencies."
    exit 1
fi

echo "Generating CMakeLists.txt from Maven NAR dependencies..."
echo "Found NAR directories:"
echo "$NAR_DIRS" | sed 's/^/  - /'
echo ""

# Find all include directories across all modules
INCLUDE_DIRS=$(find . -type d -path "*/target/nar/*/include" | sort)

# Find all library directories across all modules
LIB_DIRS=$(find . -type d -path "*/target/nar/*/lib/*/shared" | sort)

# Find all shared libraries across all modules
LIBRARIES=$(find . -path "*/target/nar/*" -name "*.so" -type f | xargs -n1 basename | sed 's/^lib//; s/\.so$//' | sort -u)

cat > CMakeLists.txt <<'EOF'
cmake_minimum_required(VERSION 3.10)
project(maven-cmake-poc)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# NAR include directories
EOF

for dir in $INCLUDE_DIRS; do
    echo "include_directories(\${CMAKE_SOURCE_DIR}/$dir)" >> CMakeLists.txt
done

cat >> CMakeLists.txt <<'EOF'

# NAR library directories
EOF

for dir in $LIB_DIRS; do
    echo "link_directories(\${CMAKE_SOURCE_DIR}/$dir)" >> CMakeLists.txt
done

cat >> CMakeLists.txt <<'EOF'

# Source files
set(SOURCES
    app/src/main/c++/main.cpp
    calculator/src/main/c++/calculator.cpp
)

# Create executable
add_executable(maven-cmake-poc ${SOURCES})

# Link against NAR libraries
target_link_libraries(maven-cmake-poc
EOF

for lib in $LIBRARIES; do
    echo "    $lib" >> CMakeLists.txt
done

cat >> CMakeLists.txt <<'EOF'
)

# Set RPATH for finding shared libraries at runtime
set_target_properties(maven-cmake-poc PROPERTIES
    BUILD_RPATH_USE_ORIGIN TRUE
    INSTALL_RPATH "\$ORIGIN/../lib"
)

# Print configuration
message(STATUS "Multi-module Maven project with NAR dependencies")
EOF

echo "Generated CMakeLists.txt successfully!"
echo ""
echo "NAR include directories found:"
echo "$INCLUDE_DIRS" | sed 's/^/  - /'
echo ""
echo "NAR libraries found:"
echo "$LIBRARIES" | sed 's/^/  - /'
echo ""
echo "To build with CMake:"
echo "  cmake -B build"
echo "  cmake --build build"
