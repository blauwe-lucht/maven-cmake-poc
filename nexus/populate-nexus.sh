#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo "Starting Nexus in background..."
/opt/sonatype/nexus/bin/nexus run &
NEXUS_PID=$!
echo "Nexus started with PID $NEXUS_PID"

echo "Waiting for Nexus to be ready..."
MAX_WAIT=300  # 5 minutes max
ELAPSED=0
until curl -s -o /dev/null -w "%{http_code}" http://localhost:8081 | grep -q "200\|403"; do
    if [ $ELAPSED -ge $MAX_WAIT ]; then
        echo "ERROR: Nexus failed to start within $MAX_WAIT seconds"
        kill $NEXUS_PID 2>/dev/null || true
        exit 1
    fi
    echo "  Waiting... (${ELAPSED}s elapsed)"
    sleep 10
    ELAPSED=$((ELAPSED + 10))
done

echo "Nexus is ready!"

# Get admin password
ADMIN_PASSWORD=$(cat /nexus-data/admin.password)

echo "Accepting EULA..."
# Get the EULA text first
EULA_JSON=$(curl -s -u admin:$ADMIN_PASSWORD -X GET "http://localhost:8081/service/rest/v1/system/eula")
echo "EULA JSON received: $EULA_JSON"

# Accept the EULA by posting it back with accepted: true
# Note: JSON has spaces around the colon
EULA_ACCEPTED=$(echo "$EULA_JSON" | sed 's/"accepted" : false/"accepted" : true/')
echo "Sending EULA acceptance: $EULA_ACCEPTED"

EULA_RESPONSE=$(echo "$EULA_ACCEPTED" | curl -s -w "\nHTTP_STATUS:%{http_code}" -u admin:$ADMIN_PASSWORD -X POST "http://localhost:8081/service/rest/v1/system/eula" \
  -H "Content-Type: application/json" \
  -d @-)
echo "EULA acceptance response: $EULA_RESPONSE"

# Verify EULA was accepted
EULA_CHECK=$(curl -s -u admin:$ADMIN_PASSWORD -X GET "http://localhost:8081/service/rest/v1/system/eula")
echo "EULA status after acceptance: $EULA_CHECK"

echo "Creating Maven releases repository for NARs..."
REPO_RESPONSE=$(curl -u admin:$ADMIN_PASSWORD -X POST "http://localhost:8081/service/rest/v1/repositories/maven/hosted" \
  -H "Content-Type: application/json" \
  -w "\nHTTP_STATUS:%{http_code}" \
  -d '{
    "name": "maven-nar-releases",
    "online": true,
    "storage": {
      "blobStoreName": "default",
      "strictContentTypeValidation": false,
      "writePolicy": "ALLOW"
    },
    "maven": {
      "versionPolicy": "RELEASE",
      "layoutPolicy": "STRICT"
    }
  }')
echo "Repository creation response: $REPO_RESPONSE"

# Verify repository was created
echo "Verifying repository exists..."
curl -u admin:$ADMIN_PASSWORD "http://localhost:8081/service/rest/v1/repositories/maven/hosted/maven-nar-releases"
echo ""

# Test admin credentials
echo "Testing admin credentials..."
curl -u admin:$ADMIN_PASSWORD -I "http://localhost:8081/service/rest/v1/status"
echo ""

echo "Cloning boost-nar..."
cd /tmp
git clone https://github.com/markjohndoyle/boost-nar.git
cd boost-nar

echo "Building and deploying boost-nar artifacts to Nexus..."
# URL-encode the password for embedding in URL
URL_ENCODED_PASSWORD=$(echo -n "$ADMIN_PASSWORD" | sed 's/@/%40/g; s/:/%3A/g; s/#/%23/g; s/\//%2F/g; s/?/%3F/g')

# Escape special XML characters in password for settings.xml
ESCAPED_PASSWORD=$(echo "$ADMIN_PASSWORD" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&apos;/g')

# Create Maven settings with admin credentials
cat > settings.xml <<EOF
<settings>
  <servers>
    <server>
      <id>nexus</id>
      <username>admin</username>
      <password>${ESCAPED_PASSWORD}</password>
    </server>
  </servers>
</settings>
EOF

echo "Verifying settings.xml contents..."
cat settings.xml

echo "Attempting deployment with Maven..."
# Build and deploy using Maven with admin credentials
mvn -s settings.xml clean install deploy -DskipTests \
  -DaltDeploymentRepository=nexus::default::http://localhost:8081/repository/maven-nar-releases/

echo "Stopping Nexus..."
kill $NEXUS_PID 2>/dev/null || true
# Give Nexus time to shut down gracefully
sleep 10

echo "NAR artifacts deployed successfully!"
