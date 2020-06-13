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

    local latest_tag
    latest_tag=$(find_latest_tag)

    local latest_tag_rev
    latest_tag_rev=$(git rev-parse --verify "$latest_tag")
    echo "$latest_tag_rev $latest_tag (latest tag)"

    local head_rev
    head_rev=$(git rev-parse --verify HEAD)
    echo "$head_rev HEAD"

    if [[ "$latest_tag_rev" == "$head_rev" ]]; then
        echo "No code changes. Nothing to release."
        exit
    fi

    rm -rf .cr-release-packages
    mkdir -p .cr-release-packages

    rm -rf .cr-index
    mkdir -p .cr-index

    echo "Identifying changed charts since tag '$latest_tag'..."

    local changed_charts=()
    local charts_path='*/Chart.yaml' # we consider only charts dirs at level one
    readarray -t changed_charts <<< "$(git diff --find-renames --name-only "$latest_tag_rev" -- $charts_path | cut -d '/' -f 1 | uniq)"

    if [[ -n "${changed_charts[*]}" ]]; then
        for chart in "${changed_charts[@]}"; do
            echo "Packaging chart '$chart'..."
            package_chart "$chart"
        done

        release_charts
        update_index
    else
        echo "Nothing to do. No chart changes detected."
    fi

    popd > /dev/null
}

find_latest_tag() {
    if ! git describe --tags --abbrev=0 2> /dev/null; then
        git rev-list --max-parents=0 --first-parent HEAD
    fi
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

    git config user.email "circleci@users.noreply.github.com"
    git config user.name "circleci"

    git checkout gh-pages
    cp --force .cr-index/index.yaml index.yaml
    git add index.yaml
    git commit --message="Update index.yaml" --signoff
    git push origin gh-pages
}

main