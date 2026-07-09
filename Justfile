set dotenv-load

branch := env("BUILD_BRANCH", "44")
tag := env("BUILD_TAG", branch)

registry := env("BUILD_REGISTRY", "localhost")
name := env("BUILD_IMAGE", "aquarium")

base := env("BUILD_BASE", "quay.io/fedora/fedora-silverblue:" + branch)

rechunk_suffix := env("BUILD_RECHUNK_SUFFIX", "-build")
arch := env("BUILD_ARCH", "amd64")

[private]
pull-base *ARGS:
    podman pull {{ARGS}} {{base}}

[private]
pull-chunkah *ARGS:
    podman pull {{ARGS}} quay.io/coreos/chunkah

[private]
pull-img *ARGS:
    podman pull {{ARGS}} {{registry}}/{{name}}:44
    podman pull {{ARGS}} {{registry}}/{{name}}:{{tag}} || true

[parallel]
pull *ARGS: (pull-base ARGS) (pull-chunkah ARGS) (pull-img ARGS)

build *ARGS:
    buildah bud \
        --layers=true \
        --skip-unused-stages=false \
        --arch="{{arch}}" \
        --build-arg="base={{base}}" \
        --build-arg="CHUNKAH_CONFIG_STR=$(podman inspect {{registry}}/{{name}}:44)" \
        -v=$(pwd):/run/src \
        --security-opt=label=disable \
        {{ARGS}} \
        -t "{{registry}}/{{name}}:{{tag}}" \
        "."

sign digest:
    cosign sign -y --new-bundle-format=false --use-signing-config=false --key env://SIGNING_KEY "{{registry}}/{{name}}@{{digest}}"
