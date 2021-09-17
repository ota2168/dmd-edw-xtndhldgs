#!/bin/bash

# Stop at any error, treat unset vars as errors and make pipelines exit
# with a non-zero exit code if any command in the pipeline exits with a
# non-zero exit code.
set -o errexit
set -o nounset
set -o pipefail


die() {
    >&2 printf '%s\n' "${1}"
    exit 1
}


# List artifacts.
ls -l --si -- "${ARTIFACT_DIR}"


echo "Determing normalized package version"
pushd -- "${ARTIFACT_DIR}" &> /dev/null
package_name="$(python -c 'from pathlib import Path; from pkginfo import SDist; print(SDist(next(Path(".").glob("*.tar.gz"))).name)')"
package_version="$(python -c 'from pathlib import Path; from pkginfo import SDist; print(SDist(next(Path(".").glob("*.tar.gz"))).version)')"

if [ "$package_version" = "0.0.1" ]; then
    die "Will not deploy package with version 0.0.1"


# Artifactory (or twine) swaps underscores for dashes, so we must do the same
package_name=${package_name/_/-}

popd &> /dev/null
printf '%s\n' "Package name: ${package_name}" "Package version: ${package_version}"

if [ "$package_name" = "dmd-project" ]; then
    die "Will not deploy package named dmd-project"
fi


# Check if artifacts corresponding to this package version have already
# been uploaded to Artifactory.
response="$(mktemp)"
response_code="$(
    curl \
        --output "${response}" \
        --request GET \
        --silent \
        --url "https://artifactory.awsmgmt.massmutual.com/artifactory/api/storage/cx-pypi-local/${package_name}/${package_version}" \
        --write-out '%{http_code}'
)"
if [[ "${response_code}" -eq 404 ]]; then
    printf '%s\n' "${package_name} v${package_version} not found in Artifactory."
elif [[ "${response_code}" -eq 200 ]]; then
    die "ERROR: artifacts for ${package_name} version ${package_version} already exist in Artifactory"
else
    >&2 cat -- "${response}"
    die "ERROR: halting due to unexpected response code ${response_code}"
fi


# Upload artifacts to Artifactory.
python -m twine upload \
    --disable-progress-bar \
    --repository-url https://artifactory.awsmgmt.massmutual.com/artifactory/api/pypi/cx-pypi-local \
    --verbose \
    -- \
    "${ARTIFACT_DIR}"/*
