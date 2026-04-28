ARG base

# Context

FROM scratch AS ctx
COPY build_files /build_files

# Image

FROM $base

COPY --chmod=644 files/repos/*.repo /etc/yum.repos.d/

RUN --mount=type=bind,from=ctx,source=/build_files,target=/ctx \
    --mount=type=cache,target=/var/cache \
    /ctx/build && \
    /ctx/cleanup && \
    /ctx/finalize

RUN bootc container lint --no-truncate
