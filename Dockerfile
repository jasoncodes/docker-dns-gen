FROM alpine:latest AS base

ARG S6_OVERLAY_VERSION=3.1.0.1
ARG ĴWILDER_DOCKER_GEN_VERSION=0.9.0

ARG S6_OVERLAY_RELEASE_SCRIPTS=https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz

FROM base AS base-amd64
ARG S6_OVERLAY_RELEASE_BIN=https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz
ARG JWILDER_DOCKER_GEN_RELEASE=https://github.com/jwilder/docker-gen/releases/download/${ĴWILDER_DOCKER_GEN_VERSION}/docker-gen-alpine-linux-amd64-${ĴWILDER_DOCKER_GEN_VERSION}.tar.gz

FROM base AS base-arm64
ARG S6_OVERLAY_RELEASE_BIN=https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-aarch64.tar.xz
ARG JWILDER_DOCKER_GEN_RELEASE=https://github.com/jwilder/docker-gen/releases/download/${ĴWILDER_DOCKER_GEN_VERSION}/docker-gen-alpine-linux-arm64-${ĴWILDER_DOCKER_GEN_VERSION}.tar.gz

FROM base-$TARGETARCH AS build

RUN apk --no-cache add curl binutils
RUN mkdir -p /build/usr/local/bin

RUN curl -L ${S6_OVERLAY_RELEASE_SCRIPTS} | tar -C /build -Jxp
RUN curl -L ${S6_OVERLAY_RELEASE_BIN} | tar -C /build -Jxp

RUN curl -L ${JWILDER_DOCKER_GEN_RELEASE} | tar -C /build/usr/local/bin -xz && strip /build/usr/local/bin/docker-gen

FROM base-$TARGETARCH

ENV DOCKER_HOST unix:///var/run/docker.sock

RUN apk --no-cache add dnsmasq bind-tools

COPY --from=build build/. /

COPY files/. /

EXPOSE 53/udp

ENTRYPOINT ["/init"]
