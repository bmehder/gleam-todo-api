# 1. Build image
FROM ghcr.io/gleam-lang/gleam:latest AS builder

WORKDIR /app

# Copy project files
COPY . .

# Compile
RUN gleam build

# 2. Runtime image
FROM erlang:26

WORKDIR /app

# Copy build artifacts
COPY --from=builder /app/build ./build
COPY --from=builder /app/gleam.toml /app/gleam.toml

# Expose port 3000 (Render detects this)
EXPOSE 3000

# Start the server
CMD ["erl", "-pa", "build/dev/erlang", "-eval", "todolist_api:main()"]