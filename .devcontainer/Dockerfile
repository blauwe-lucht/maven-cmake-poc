FROM almalinux:9

# Install development tools and build essentials
RUN dnf -y update && \
    dnf -y groupinstall "Development Tools" && \
    dnf -y install \
    java-11-openjdk-headless \
    maven \
    gcc-c++ \
    cmake \
    python3 \
    python3-pip \
    git \
    wget \
    which \
    vim \
    bc \
    time \
    && dnf clean all

# Install Conan
RUN pip3 install conan

# Create non-root user
RUN useradd -m -s /bin/bash developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copy Maven settings to configure Nexus
COPY .devcontainer/settings.xml /home/developer/.m2/settings.xml
RUN chown -R developer:developer /home/developer/.m2

# Set up environment
ENV JAVA_HOME=/usr/lib/jvm/jre-11-openjdk
ENV PATH="${PATH}:/usr/local/bin"

USER developer
WORKDIR /workspace

# Verify installations
RUN mvn --version && \
    g++ --version && \
    conan --version && \
    cmake --version
