# Build stage
FROM golang:1.26-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache git

# Copy only the dependency files first for better caching
COPY mcp/go.mod mcp/go.sum* ./mcp/

# Set working directory to mcp for go mod commands
WORKDIR /app/mcp
RUN go mod download

# Copy the rest of the mcp source code
COPY mcp/ .

# Build the binary with static linking
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/rad-calc main.go

# Run stage
FROM alpine:latest

# Add security updates and CA certificates
RUN apk --no-cache add ca-certificates tzdata

WORKDIR /app

# Copy the binary from the builder stage
COPY --from=builder /app/rad-calc .

# Expose the default port
EXPOSE 8080

# Set healthcheck
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/ || exit 1

# Run the binary
ENTRYPOINT ["./rad-calc", "-http", "-port", "8080"]
