FROM maven:3.9.6-eclipse-temurin-17-focal

RUN apt-get update && apt-get install -y \
     ca-certificates \
     curl \
     gnupg \
     lsb-release && \
     mkdir -p /etc/apt/keyrings && \
     curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
     echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
     apt-get update && \
     apt-get install -y docker-ce-cli && \
     cp /usr/bin/docker /usr/local/bin/docker-custom && \
     rm -rf /var/lib/apt/lists/*

# CHANGE THIS LINE: Add the --client flag
RUN docker-custom --version
