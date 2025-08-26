# --- Build Stage ---
# Use a Go base image that is compatible with your installed version (1.23)
FROM golang:1.23-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy the go.mod and go.sum files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the application source code into the container
COPY . .

# Build the Go application, making it a static binary
RUN CGO_ENABLED=0 go build -o /user-service

# --- Run Stage ---
# Use a minimal, secure base image for the final container
FROM alpine:latest

# Set the working directory
WORKDIR /root/

# Copy the compiled binary from the builder stage
COPY --from=builder /user-service .

# Expose the port the service runs on
EXPOSE 5000

# Run the compiled executable
CMD ["./user-service"]
