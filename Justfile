set dotenv-load

branch := env("BUILD_BRANCH", "44")
tag := env("BUILD_TAG", branch)

registry := env("BUILD_REGISTRY", "localhost")
name := env("BUILD_IMAGE", "aquarium")

base := env("BUILD_BASE", "quay.io/shadowblue/base:" + branch)

rechunk_suffix := env("BUILD_RECHUNK_SUFFIX", "-build")
arch := env("BUILD_ARCH", "amd64")

pull *ARGS:
    podman pull {{base}}
    podman pull {{registry}}/{{name}}:{{tag}} || true

build *ARGS:
    buildah bud \
        --layers=true \
        --arch="{{arch}}" \
        --build-arg="base={{base}}" \
        {{ARGS}} \
        -t "{{registry}}/{{name}}:{{tag}}{{rechunk_suffix}}" \
        "."

rechunk *ARGS:
    podman run --rm --privileged -v /var/lib/containers:/var/lib/containers {{ARGS}} \
        {{base}} \
        rpm-ostree experimental compose build-chunked-oci \
            --bootc \
            --format-version=1 \
            --from={{registry}}/{{name}}:{{tag}}{{rechunk_suffix}} \
            --output=containers-storage:{{registry}}/{{name}}:{{tag}}

sign digest:
    cosign sign -y --new-bundle-format=false --key env://SIGNING_KEY "{{registry}}/{{name}}@{{digest}}"
