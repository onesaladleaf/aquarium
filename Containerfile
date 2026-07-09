ARG base
ARG CHUNKAH_CONFIG_STR

# Context

FROM scratch AS ctx
COPY build_files /build_files
COPY modules /modules

# Image

FROM $base as builder

COPY cosign.pub /etc/pki/containers/aquarium.pub
COPY files/etc/ /etc/
COPY files/usr/ /usr/

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,target=/var/cache \
    /ctx/build_files/build && \
    /ctx/build_files/cleanup && \
    /ctx/build_files/finalize

RUN bootc container lint --no-truncate

# Chunkah

FROM quay.io/coreos/chunkah AS chunkah
ARG CHUNKAH_CONFIG_STR
RUN --mount=from=builder,src=/,target=/chunkah,ro \
    --mount=type=bind,target=/run/src,rw \
    chunkah build \
        --prune /sysroot/ \
        --label ostree.commit- \
        --label ostree.final-diffid- \
        --max-layers=128 \
        --output oci:/run/src/out && \
    ls -la /run/src/out

FROM oci:out
