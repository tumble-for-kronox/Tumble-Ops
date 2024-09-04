#!/bin/bash

# Assuming Linux/WSL/MacOS (unix-like) environment and setup kubectl, helm, and minikube
# Example usage: ./setup.sh <ghcr_token> <secrets_file>

_initialize() {
    curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.30.0/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl

    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh

    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube

    sudo apt-get update
    sudo apt-get install -y jq

    if minikube status | grep -q "Running"; then
        minikube stop
    fi
    minikube start --driver=docker

    _create_context

    rm get_helm.sh
    rm minikube-linux-amd64
}

_create_context() {
    kubectl config set-context minikube --cluster=minikube --user=minikube
    kubectl config use-context minikube
}

_deploy_cluster() {
    helm template cluster ../cluster > cluster.yml
    kubectl apply -f cluster.yml
    rm cluster.yml
}

_deploy_middleware() {
    for dir in ../middleware/*; do
        namespace=$(basename "$dir")
        for component in "$dir"/*; do
            component_name=$(basename "$component")
            echo $component_name
            helm dependency update "$component"
            helm template $component_name $component -n $namespace > $component_name.yml
            kubectl apply -f $component_name.yml -n $namespace
            rm $component_name.yml
        done
    done
}

_deploy_backend() {
    helm template tumble-backend ../backend -n development > tumble-backend.yml
    kubectl apply -f tumble-backend.yml -n development
    rm tumble-backend.yml
}

_create_secrets() {
    ghcr_token=$1
    secrets_file=$2

    kubectl create secret docker-registry ghcr-secret -n development --docker-server=ghcr.io --docker-username=tumble-for-kronox --docker-password=$ghcr_token
    kubectl create secret generic tumble-backend-secrets -n development --from-file=$secrets_file
}

if [ "$#" -ne 2 ]; then
    echo "Error: Two arguments required: <ghcr_token> <secrets_file>"
    exit 1
fi

_initialize
_deploy_cluster
_create_secrets "$@"
_deploy_middleware
_deploy_backend
