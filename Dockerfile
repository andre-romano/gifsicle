# syntax=docker/dockerfile:1.7

ARG DEBIAN_VERSION=12

# STAGE 1 - build
FROM debian:${DEBIAN_VERSION}-slim AS build

# BUILD FROM SOURCE:
ARG APP_NAME=gifsicle
ARG APP_VERSION=v1.96

ARG GIT_REPOSITORY=https://github.com/kohler/gifsicle.git

RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/tmp/build \
    apt-get update \
    && echo "Installing dependencies ..." \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    build-essential \
    autoconf \
    automake \
    libtool \
    make \    
    nasm \
    pkg-config \
    && echo "Building ${APP_NAME} ..." \
    && git clone ${GIT_REPOSITORY} /tmp/build \
    && cd /tmp/build \
    && git checkout ${APP_VERSION} \
    && autoreconf -i \
    && ./configure \ 
    --prefix=/usr/local \
    --disable-gifview \
    LDFLAGS="-static" \
    && make -j$(nproc) \
    && make install \
    && echo "Building ${APP_NAME} ... OK" 

# STAGE 2 - RELEASE
FROM debian:${DEBIAN_VERSION}-slim AS release
COPY --from=build /usr/local/bin /usr/local/bin

# define app userspace
WORKDIR /app
CMD [ "${APP_NAME}" ]
