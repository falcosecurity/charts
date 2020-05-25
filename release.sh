#!/bin/bash

if [ ! -d ../gh-pages/.git ]; then
    echo "Need to set up 'gh-pages' clone in directory above for this script to work"
    echo "Run:"
    echo "cd .."
    echo "git clone git@github.com/falcosecurity/charts gh-pages"
    echo "cd gh-pages"
    echo "git checkout gh-pages"
    exit 1
fi

helm package falco
mv *.tgz ../gh-pages/
pushd ../gh-pages
git checkout gh-pages

#TODO rename to falcosecurity before merge
helm repo index . --url https://falcosecurity.github.com/charts

# Create json representation (because my browser wont render yaml)
cat index.yaml | python -c 'import sys, yaml, json; y=yaml.load(sys.stdin.read()); print json.dumps(y)' | jq '.' > index.json

git add .

git commit -m "Helm chart/repo release $(date +%F)"

git push origin gh-pages
