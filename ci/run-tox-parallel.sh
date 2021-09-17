#!/bin/bash

# Stop at any error, treat unset vars as errors and make pipelines exit
# with a non-zero exit code if any command in the pipeline exits with a
# non-zero exit code.
set -o errexit
set -o nounset
set -o pipefail

echo "Running tox in parallel on: ${TOX_ENVS}"
python -m tox --parallel=auto -e "${TOX_ENVS}"
