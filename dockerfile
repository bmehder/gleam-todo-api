# ---- Build stage ----
FROM erlang:26 AS builder

WORKDIR /app

# Install build deps
RUN apt-get update && apt-get install -y \
  wget \
  curl \
  xz-utils \
  build-essential

# Install Gleam v1.13.0 (compatible with gleam_json requirements)
RUN wget https://github.com/gleam-lang/gleam/releases/download/v1.13.0/gleam-v1.13.0-x86_64-unknown-linux-musl.tar.gz \
  && tar -xzf gleam-v1.13.0-x86_64-unknown-linux-musl.tar.gz \
  && mv gleam /usr/local/bin/gleam

# Copy project files
COPY . .

# Build project
RUN gleam build --target erlang


# ---- Runtime stage ----
FROM erlang:26

WORKDIR /app

COPY --from=builder /app/build ./build
COPY --from=builder /app/gleam.toml ./gleam.toml

ENV ERL_LIBS="/app/build/erlang"

EXPOSE 3000

CMD ["/bin/sh", "-c", "erl -pa build/erlang -pa build/packages/*/_gleam_artefacts/erlang/*/ebin -noshell -eval 'todolist_api:main(), init:stop()'"]