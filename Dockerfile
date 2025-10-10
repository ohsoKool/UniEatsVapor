# ================================
# Step 1 — Build image
# ================================
FROM swift:6.1-noble AS build

WORKDIR /app

# Copy package files and resolve dependencies
COPY Package.* ./
RUN swift package resolve

# Copy source code
COPY . .

# Build in release mode
RUN swift build --configuration release --product UniEatsVapor

# ================================
# Step 2 — Run image
# ================================
FROM ubuntu:22.04

# Install necessary runtime libraries for Swift apps
RUN apt-get update && apt-get install -y \
    libatomic1 libicu70 libbsd0 libcurl4 ca-certificates tzdata \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy built binary from builder
COPY --from=build /app/.build/release/UniEatsVapor .

# ===== NEW: Copy Swift runtime libraries =====
COPY --from=build /usr/lib/swift /usr/lib/swift
ENV LD_LIBRARY_PATH=/usr/lib/swift:$LD_LIBRARY_PATH

# Expose Vapor port
EXPOSE 8080

# Run the Vapor app
CMD ["./UniEatsVapor", "serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
