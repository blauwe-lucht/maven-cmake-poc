FROM sonatype/nexus3:3.85.0

USER root

# Install git, maven, and build tools to build and deploy boost-nar
RUN microdnf install -y git maven gcc gcc-c++ make && microdnf clean all

# Copy script to populate Nexus (while still root)
COPY --chmod=755 populate-nexus.sh /tmp/populate-nexus.sh

# Create .m2 directory for Maven with proper permissions for nexus user
RUN mkdir -p /opt/sonatype/nexus/.m2 && chown -R nexus:nexus /opt/sonatype/nexus/.m2

USER nexus

# Start Nexus, wait for it, then populate with NARs
RUN /tmp/populate-nexus.sh

# Start Nexus when container runs
CMD ["/opt/sonatype/nexus/bin/nexus", "run"]
