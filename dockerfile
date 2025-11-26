# ---- Build stage ----
FROM erlang:26 AS builder

WORKDIR /app

# Install build deps
RUN apt-get update && apt-get install -y \
  wget \
  curl \
  xz-utils \
  build-essential

# Install Gleam v1.11.0 (confirmed valid)
RUN wget https://github.com/gleam-lang/gleam/releases/download/v1.11.0/gleam-v1.11.0-x86_64-unknown-linux-musl.tar.gz \
  && tar -xzf gleam-v1.11.0-x86_64-unknown-linux-musl.tar.gz \
  && mv gleam /usr/local/bin/gleam

# Copy project files
COPY . .

# Build project
RUN gleam build --target erlang


# ---- Runtime stage ----
FROM erlang:26

WORKDIR /app

# Copy compiled output
COPY --from=builder /app/build ./build
COPY --from=builder /app/gleam.toml ./gleam.toml

# Let Erlang find BEAM files
ENV ERL_LIBS="/app/build/dev"

EXPOSE 3000

CMD ["erl", "-pa", "build/dev/erlang", "-eval", "todolist_api:main()"]