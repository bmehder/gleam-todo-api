# Force cache busting on Render
ARG FORCE_REBUILD=1

# ---- Build stage ----
FROM erlang:26 AS builder

WORKDIR /app

# Install Gleam
RUN wget https://github.com/gleam-lang/gleam/releases/download/v1.13.0/gleam-v1.13.0-x86_64-unknown-linux-musl.tar.gz \
  && tar -xzf gleam-v1.13.0-x86_64-unknown-linux-musl.tar.gz \
  && mv gleam /usr/local/bin/gleam

# Copy all source files
COPY . .

# Build project
RUN gleam build --target erlang

# ---- Runtime stage ----
FROM erlang:26

WORKDIR /app

# Copy build artifacts
COPY --from=builder /app/build ./build
COPY --from=builder /app/gleam.toml ./gleam.toml

CMD ["erl", "-pa", "build/dev/erlang/*/ebin", "-eval", "todolist_api:main()"]