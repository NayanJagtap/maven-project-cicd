# Use a stable Maven image with Java 17 (or your preferred version)
FROM maven:3.9.6-eclipse-temurin-17-focal

# Install Docker CLI and other utilities
# 'focal' is Ubuntu 20.04, which is highly compatible with Docker
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release && \
    # Add Docker’s official GPG key
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    # Set up the repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    # Install only the CLI (we don't need the full engine inside the agent)
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    # Clean up to keep the image small
    rm -rf /var/lib/apt/lists/*

# Verify installations
RUN mvn -version && docker --version
