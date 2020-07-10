#!/usr/bin/env sh

set -o errexit
set -o nounset
set -o pipefail

readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"

main() {
    cd "$REPO_ROOT" > /dev/null

    echo "Linting charts..."

    # iterate over all charts
    for chart_config in */Chart.yaml; do
        helm lint $(dirname $chart_config)
    done
}

main
