#!/bin/bash

# Source this shell script to prepare a user's local environment to run
# tests inside of a Docker container.

set -o errexit
set -o nounset
set -o pipefail


registry=registry.ucp.cxmgmtawsprd.massmutual.com
image="${registry}/datascience/manylinux2010_x86_64:0.5.0"  # keep in sync with ci/pod.yaml


_pull_testing_image() {
    if docker image inspect -- "${image}" &> /dev/null; then
        echo "Docker image ${image} available"
    else
        echo "Logging into Docker registry ${registry}… (enter your Active Directory password)" \
            && docker login -u "${USER}" -- "${registry}" \
            && echo 'Logged into Docker registry.' \
            && echo "Pulling Docker image ${image}…" \
            && docker image pull -- "${image}" \
            && echo 'Pulled Docker image.'
    fi
}

run() {
    docker container run \
        --interactive \
        --mount type=bind,source="$(pwd)",target=/mnt/target \
        --rm \
        --tty \
        --workdir /mnt/target \
        -- \
        "${image}" \
        "${@}"
}

run_citests() {
    # Run CI Tests in local Docker container
    run python -m tox -e clean,build,pre-commit-lint,black,flake8,mypy,isort,py35,py36,py37
}
