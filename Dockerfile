# syntax=docker/dockerfile:1.3

# Stage 1: Builder for x86_64
FROM rust:1.72.0 as builder-x86_64

# Install cross-compilation tools
RUN apt-get update && apt-get install -y \
    gcc-x86-64-linux-gnu \
    libc6-dev-amd64-cross \
    binutils-x86-64-linux-gnu \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add the target for cross-compilation
RUN rustup target add x86_64-unknown-linux-gnu

# Set up working directory
WORKDIR /usr/src/app

# Copy the source code
COPY . .

# Build the binary for x86_64
RUN cargo build --release --target=x86_64-unknown-linux-gnu

# Stage 2: Builder for aarch64
FROM rust:1.72.0 as builder-aarch64

# Install cross-compilation tools
RUN apt-get update && apt-get install -y \
    gcc-aarch64-linux-gnu \
    libc6-dev-arm64-cross \
    binutils-aarch64-linux-gnu \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add the target for cross-compilation
RUN rustup target add aarch64-unknown-linux-gnu

# Set up working directory
WORKDIR /usr/src/app

# Copy the source code
COPY . .

# Build the binary for aarch64
RUN cargo build --release --target=aarch64-unknown-linux-gnu

# Stage 3: Create the final image for x86_64
FROM ubuntu:22.04 as runtime-x86_64

RUN apt-get update && apt-get install -y \
    libssl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a new user and group
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Set up working directory
WORKDIR /home/appuser/app

# Copy the binary from the build stage
COPY --from=builder-x86_64 /usr/src/app/target/x86_64-unknown-linux-gnu/release/qr_code_server .

# Set the ownership and permissions
RUN chown -R appuser:appgroup /home/appuser/app
USER appuser

# Run
CMD ["./qr_code_server"]

# Stage 4: Create the final image for aarch64
FROM ubuntu:22.04 as runtime-aarch64

RUN apt-get update && apt-get install -y \
    libssl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a new user and group
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Set up working directory
WORKDIR /home/appuser/app

# Copy the binary from the build stage
COPY --from=builder-aarch64 /usr/src/app/target/aarch64-unknown-linux-gnu/release/qr_code_server .

# Set the ownership and permissions
RUN chown -R appuser:appgroup /home/appuser/app
USER appuser

# Run
CMD ["./qr_code_server"]
