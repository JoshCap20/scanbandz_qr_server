# Use the official Rust image as the build environment
FROM rust:1.72.0 as builder

# Install necessary tools for cross-compilation
RUN apt-get update && apt-get install -y \
    gcc-aarch64-linux-gnu \
    libc6-dev-arm64-cross \
    binutils-aarch64-linux-gnu

# Set the working directory
WORKDIR /usr/src/app

# Copy the source code
COPY . .

# Build the application for the ARM architecture
RUN rustup target add aarch64-unknown-linux-gnu
RUN cargo build --release --target=aarch64-unknown-linux-gnu

# Use an Alpine base image for the runtime
FROM alpine:3.18

# Install necessary runtime dependencies
RUN apk add --no-cache libssl1.1

# Set the working directory
WORKDIR /home/appuser/app

# Add a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /usr/src/app/target/aarch64-unknown-linux-gnu/release/qr_code_server .

USER appuser

# Expose the port the app runs on
EXPOSE 8080

# Run the application
CMD ["./qr_code_server"]
