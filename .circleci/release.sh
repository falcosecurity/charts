#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

: "${GITHUB_TOKEN:?Environment variable GITHUB_TOKEN must be set}"
: "${CR_REPO_URL:?Environment variable CR_REPO_URL must be set}"
: "${GIT_USERNAME:?Environment variable GIT_USERNAME must be set}"
: "${GIT_REPOSITORY_NAME:?Environment variable GIT_REPOSITORY_NAME must be set}"

readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"
export CR_TOKEN="$GITHUB_TOKEN"

main() {
    pushd "$REPO_ROOT" > /dev/null

    echo "Fetching tags..."
    git fetch --tags

    echo "Fetching charts..."

    local changed_charts=()

    # iterate over all charts and skip those that already have a tag matching the current version
    for chart_config in */Chart.yaml; do
        local chart_name
        local chart_ver
        local tag

        chart_name=$(awk '/^name: /{print $NF}' < "$chart_config" )
        chart_ver=$(awk '/^version: /{print $NF}' < "$chart_config")
        tag="${chart_name}-${chart_ver}"
        if git rev-parse "$tag" >/dev/null 2>&1; then
            echo "Chart '$chart_name': tag '$tag' already exists, skipping."
        else
            echo "Chart '$chart_name': new version '$chart_ver' detected."
            changed_charts+=("$chart_name")
        fi
    done

    # preparing dirs
    rm -rf .cr-release-packages
    mkdir -p .cr-release-packages

    rm -rf .cr-index
    mkdir -p .cr-index

    # only release those charts for which a new version has been detected
    if [[ -n "${changed_charts[*]}" ]]; then
        for chart in "${changed_charts[@]}"; do
            echo "Packaging chart '$chart'..."
            package_chart "$chart"
        done

        release_charts

        # the newly created GitHub releases may not be available yet; let's wait a bit to be sure.
        sleep 5

        update_index
    else
        echo "Nothing to do. No chart changes detected."
    fi

    popd > /dev/null
}

package_chart() {
    local chart="$1"
    helm package "$chart" --destination .cr-release-packages --dependency-update
}

release_charts() {
    cr upload -o "$GIT_USERNAME" -r "$GIT_REPOSITORY_NAME"
}

update_index() {
    cr index -o "$GIT_USERNAME" -r "$GIT_REPOSITORY_NAME" -c "$CR_REPO_URL"

    git config user.email "poiana@users.noreply.github.com"
    git config user.name "poiana"

    git checkout gh-pages
    cp --force .cr-index/index.yaml index.yaml
    git add index.yaml
    git commit --message="Update index.yaml" --signoff
    git push origin gh-pages
}

main
