# 1. Build stage
FROM ghcr.io/gleam-lang/gleam:1.3.1 AS builder

WORKDIR /app

# Copy the project files
COPY . .

# Build the project
RUN gleam build --target erlang

# 2. Runtime stage
FROM erlang:26

WORKDIR /app

# Copy build artifacts
COPY --from=builder /app/build ./build
COPY --from=builder /app/gleam.toml ./gleam.toml

# Let Erlang find BEAM files
ENV ERL_LIBS="/app/build/dev"

EXPOSE 3000

CMD ["erl", "-pa", "build/dev/erlang", "-eval", "todolist_api:main()"]