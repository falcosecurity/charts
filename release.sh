#!/bin/bash

# todo(leogr): this is a temporary script, the release process needs to be automated.
set -e

TMP_DIR=/tmp

FALCO_CHART_VERSION=$(cat ./falco/Chart.yaml | awk '/version: /{print $NF}')
RELEASE_BRANCH=release/falco-${FALCO_CHART_VERSION}

git fetch origin

helm lint falco
helm package falco
mv falco-${FALCO_CHART_VERSION}.tgz ${TMP_DIR}/falco-${FALCO_CHART_VERSION}.tgz

git checkout -q -b ${RELEASE_BRANCH} --no-track origin/gh-pages

mv -f ${TMP_DIR}/falco-${FALCO_CHART_VERSION}.tgz .
helm repo index . --url https://falcosecurity.github.io/charts

# todo(leogr): can we remove this?
# Create json representation (because my browser wont render yaml)
cat index.yaml | python -c 'import sys, yaml, json; y=yaml.load(sys.stdin.read()); print(json.dumps(y))' | jq '.' > index.json

git add .

git commit -s -m "update(falco): chart release ${FALCO_CHART_VERSION}"

git push -u origin ${RELEASE_BRANCH}

echo ""
echo "IMPORTANT NOTE:"
echo "To complete the release, create a new pull request from '${RELEASE_BRANCH}' to 'gh-pages':"
echo "https://github.com/falcosecurity/charts/compare/gh-pages...${RELEASE_BRANCH}?expand=1"