# ---- Build stage ----
FROM alpine:3.19 AS builder

# Install build dependencies
RUN apk add --no-cache \
  curl \
  wget \
  gcc \
  g++ \
  make \
  erlang-dev \
  erlang-erts \
  erlang-kernel \
  erlang-stdlib \
  erlang-tools

# Install Gleam (download official release)
RUN wget https://github.com/gleam-lang/gleam/releases/download/v1.4.0/gleam-v1.4.0-linux-amd64.tar.gz \
  && tar -xzf gleam-v1.4.0-linux-amd64.tar.gz \
  && mv gleam /usr/local/bin/gleam

WORKDIR /app

# Copy project files
COPY . .

# Build project
RUN gleam build --target erlang


# ---- Runtime stage ----
FROM erlang:26

WORKDIR /app

# Copy compiled build artifacts
COPY --from=builder /app/build ./build
COPY --from=builder /app/gleam.toml ./gleam.toml

# Let Erlang find BEAM files
ENV ERL_LIBS="/app/build/dev"

EXPOSE 3000

CMD ["erl", "-pa", "build/dev/erlang", "-eval", "todolist_api:main()"]