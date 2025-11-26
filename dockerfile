# 1. Build stage
FROM ghcr.io/gleam-lang/gleam:latest AS builder

WORKDIR /app

# Copy the project files
COPY . .

# Build the project
RUN gleam build --target erlang

# 2. Runtime stage
FROM erlang:26

WORKDIR /app

# Copy the Beam files (program + dependencies)
COPY --from=builder /app/build ./build
COPY --from=builder /app/gleam.toml ./gleam.toml

# Tell Erlang where to find the BEAM files
ENV ERL_LIBS="/app/build/dev"

# Expose port 3000 for Render to detect
EXPOSE 3000

# Start the Gleam app
CMD ["erl", "-pa", "build/dev/erlang", "-eval", "todolist_api:main()"]