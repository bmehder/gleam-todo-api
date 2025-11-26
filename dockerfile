# ---- Build stage ----
FROM erlang:26 AS builder

WORKDIR /app

# Install build deps
RUN apt-get update && apt-get install -y \
  wget \
  curl \
  xz-utils \
  build-essential

# Install Gleam (actual existing version)
RUN wget https://github.com/gleam-lang/gleam/releases/download/v1.3.2/gleam-v1.3.2-linux-amd64.tar.gz \
  && tar -xzf gleam-v1.3.2-linux-amd64.tar.gz \
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