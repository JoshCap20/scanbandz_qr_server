# Use the official Rust image as the build environment
FROM rust:1.72.0 as builder

# Set the working directory
WORKDIR /usr/src/app

# Copy the source code
COPY . .

# Build the application
RUN cargo build --release

# Use an Ubuntu base image for the runtime
FROM ubuntu:22.04

# Install necessary runtime dependencies
RUN apt-get update && apt-get install -y libssl-dev

# Set the working directory
WORKDIR /usr/src/app

# Copy the build artifact from the build stage
COPY --from=builder /usr/src/app/target/release/qr_code_server .

# Expose the port the app runs on
EXPOSE 8080

# Run the application
CMD ["./qr_code_server"]
