# Stage 1: Build the binary
FROM rust:1.72.0 as builder

# Install cross-compilation tools
RUN apt-get update && apt-get install -y \
    gcc-aarch64-linux-gnu \
    libc6-dev-arm64-cross \
    binutils-aarch64-linux-gnu \
    gcc-x86-64-linux-gnu \
    libc6-dev-amd64-cross \
    binutils-x86-64-linux-gnu \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add the target for cross-compilation
RUN rustup target add x86_64-unknown-linux-gnu aarch64-unknown-linux-gnu

# Set up working directory
WORKDIR /usr/src/app

# Copy the source code
COPY . .

# Build the binary for the specified targets
RUN cargo build --release --target=x86_64-unknown-linux-gnu
RUN cargo build --release --target=aarch64-unknown-linux-gnu

# Stage 2: Create the final image
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    libssl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a new user and group
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Set up working directory
WORKDIR /home/appuser/app

# Copy the binary from the build stage
COPY --from=builder /usr/src/app/target/x86_64-unknown-linux-gnu/release/qr_code_server /usr/src/app/target/aarch64-unknown-linux-gnu/release/qr_code_server

# Set the ownership and permissions
RUN chown -R appuser:appgroup /home/appuser/app
USER appuser

# Run
CMD ["./qr_code_server"]
