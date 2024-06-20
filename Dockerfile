# Use the official Rust image as the build environment
FROM rust:1.67.0 as builder

# Set the working directory
WORKDIR /usr/src/app

# Copy the source code
COPY . .

# Build the application
RUN cargo build --release

# Use a minimal base image for the runtime
FROM debian:buster-slim

# Set the working directory
WORKDIR /usr/src/app

# Copy the build artifact from the build stage
COPY --from=builder /usr/src/app/target/release/qr_code_server .

# Expose the port the app runs on
EXPOSE 8080

# Run the application
CMD ["./qr_code_server"]
