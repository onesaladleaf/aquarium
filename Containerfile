ARG base

# Context

FROM scratch AS ctx
COPY build_files /build_files
COPY modules /modules

# Image

FROM $base

COPY cosign.pub /etc/pki/containers/aquarium.pub
COPY files/etc/ /etc/
COPY files/usr/ /usr/

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,target=/var/cache \
    /ctx/build_files/build && \
    /ctx/build_files/cleanup && \
    /ctx/build_files/finalize

RUN bootc container lint --no-truncate
