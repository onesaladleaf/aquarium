ARG base

# Context

FROM scratch AS ctx
COPY build_files /build_files

# Image

FROM $base

COPY --chmod=644 files/repos/*.repo /etc/yum.repos.d/

COPY cosign.pub /etc/pki/containers/aquarium.pub
COPY files/sudoers.d/* /etc/sudoers.d/
COPY --chmod=644 files/signing/aquarium.yaml /etc/containers/registries.d/aquarium.yaml
COPY --chmod=644 files/signing/policy.json /etc/containers/policy.json

RUN --mount=type=bind,from=ctx,source=/build_files,target=/ctx \
    --mount=type=cache,target=/var/cache \
    /ctx/build && \
    /ctx/cleanup && \
    /ctx/finalize

RUN bootc container lint --no-truncate
