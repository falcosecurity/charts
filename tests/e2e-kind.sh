#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly CT_VERSION=v3.3.1
readonly KIND_VERSION=v0.14.0
readonly CLUSTER_NAME=falco-helm-test

run_ct_container() {
    echo 'Running ct container...'
    docker run --rm --interactive --detach --network host --name ct \
        --volume "$(pwd)/tests/ct.yaml:/etc/ct/ct.yaml" \
        --volume "$(pwd):/workdir" \
        --workdir /workdir \
        "quay.io/helmpack/chart-testing:$CT_VERSION" \
        cat
    echo
}

cleanup() {
    echo 'Removing ct container...'
    docker kill ct > /dev/null 2>&1

    echo 'Done!'
}

docker_exec() {
    docker exec --interactive ct "$@"
}

create_kind_cluster() {
    echo 'Installing kind...'

    curl -sSLo kind "https://github.com/kubernetes-sigs/kind/releases/download/$KIND_VERSION/kind-linux-amd64"
    chmod +x kind
    sudo mv kind /usr/local/bin/kind

    kind create cluster --name "$CLUSTER_NAME" --config tests/kind-config.yaml --wait 60s

    docker_exec mkdir -p /root/.kube

    echo 'Copying kubeconfig to container...'

    docker cp "$HOME/.kube/config" ct:/root/.kube/config

    docker_exec kubectl cluster-info
    echo

    echo 'Waiting for nodes to be ready...'
    docker_exec kubectl wait --for=condition=Ready nodes --all --timeout=300s
    echo

    docker_exec kubectl get nodes
    echo

    echo 'Cluster ready!'
    echo
}

install_charts() {
    docker_exec ct install
    echo
}

install_falco_if_needed(){
    status=0
    git diff --quiet HEAD master -- falco-exporter || status=1
    if [ $status -eq 1 ]; then
        echo "falco-exporter changed installing falco as well..."
        docker_exec helm repo add falcosecurity https://falcosecurity.github.io/charts
        docker_exec helm repo update
        docker_exec helm install falco falcosecurity/falco -f tests/falco-test-ci.yaml
        docker_exec kubectl get po -A
        sleep 120
        docker_exec kubectl get po -A
    fi
}

main() {
    run_ct_container
    trap cleanup EXIT

    changed=$(docker_exec ct list-changed)
    if [[ -z "$changed" ]]; then
        echo 'No chart changes detected.'
        return
    fi

    echo 'Chart changes detected.'
    create_kind_cluster
    install_falco_if_needed
    install_charts
}

main
