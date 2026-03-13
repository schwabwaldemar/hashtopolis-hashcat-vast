# ==========================================
# STAGE 1: Builder
# (Used only to clone and zip the agent)
# ==========================================
FROM ubuntu:20.04 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    zip \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/hashtopolis/agent-python.git /build && \
    cd /build && \
    ./build.sh

# ==========================================
# STAGE 2: Runtime
# (The actual image deployed to Vast.ai)
# ==========================================
FROM nvidia/cuda:12.9.1-runtime-ubuntu20.04

# Install ONLY runtime dependencies (and p7zip-full to prevent our previous crash!)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-psutil \
    python3-requests \
    pciutils \
    curl \
    p7zip-full \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root/htpclient

# Copy only the built agent from the builder stage
COPY --from=builder /build/hashtopolis.zip ./

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Move ARG and LABELs to the bottom so they don't break the build cache
ARG BUILDTIME
ARG VERSION
ARG REVISION

LABEL org.opencontainers.image.title="Hashtopolis Hashcat Vast.ai Client"
LABEL org.opencontainers.image.description="Docker container for deploying hashtopolis agents on vast.ai with hashcat"
LABEL org.opencontainers.image.url="https://github.com/kruton/hashtopolis-hashcat-vast"
LABEL org.opencontainers.image.source="https://github.com/kruton/hashtopolis-hashcat-vast"
LABEL org.opencontainers.image.created="${BUILDTIME}"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.revision="${REVISION}"

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["--auto-start"]