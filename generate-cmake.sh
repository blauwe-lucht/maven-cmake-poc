#!/bin/bash
set -euo pipefail

NAR_DIR="target/nar"

if [ ! -d "$NAR_DIR" ]; then
    echo "Error: $NAR_DIR not found. Run 'mvn compile' first to extract NAR dependencies."
    exit 1
fi

echo "Generating CMakeLists.txt from Maven NAR dependencies..."

# Find all include directories
INCLUDE_DIRS=$(find "$NAR_DIR" -type d -name include | sort)

# Find all library directories
LIB_DIRS=$(find "$NAR_DIR" -type d -path "*/lib/*/shared" | sort)

# Find all shared libraries
LIBRARIES=$(find "$NAR_DIR" -name "*.so" -type f | xargs -n1 basename | sed 's/^lib//; s/\.so$//' | sort)

cat > CMakeLists.txt <<'EOF'
cmake_minimum_required(VERSION 3.10)
project(maven-conan-poc)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Path to NAR extracted dependencies
set(NAR_DIR ${CMAKE_SOURCE_DIR}/target/nar)

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
    src/main/c++/main.cpp
    src/main/c++/calculator.cpp
)

# Create executable
add_executable(maven-conan-poc ${SOURCES})

# Link against NAR libraries
target_link_libraries(maven-conan-poc
EOF

for lib in $LIBRARIES; do
    echo "    $lib" >> CMakeLists.txt
done

cat >> CMakeLists.txt <<'EOF'
)

# Set RPATH for finding shared libraries at runtime
set_target_properties(maven-conan-poc PROPERTIES
    BUILD_RPATH_USE_ORIGIN TRUE
    INSTALL_RPATH "\$ORIGIN/../lib"
)

# Print configuration
message(STATUS "Found NAR dependencies in: ${NAR_DIR}")
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
