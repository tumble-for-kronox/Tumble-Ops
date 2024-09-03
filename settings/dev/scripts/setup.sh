#!/bin/bash

# Assuming Linux/WSL/MacOS (unix-like) environment and setup kubectl, helm, and minikube
# Example usage: ./setup.sh <ghcr_token> <secrets_file>

_initialize() {
    # Install kubectl
    curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl

    # Install helm
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh

    # Install minikube
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube

    # Create context in kubeconfig file so as to not interfere with existing contexts (possibly prod)
    _create_context

    # Check if minikube is already running, then restart it, otherwise start it
    if minikube status | grep -q "Running"; then
        minikube stop
    fi
    minikube start --driver=docker --memory=4096 --cpus=2

    # Enable ingress
    minikube addons enable ingress

    # Clean up
    rm get_helm.sh
    rm minikube-linux-amd64
}

# Create necessary context in kubeconfig file for local development
_create_context() {
    kubectl config set-context minikube --cluster=minikube --user=minikube
    kubectl config use-context minikube
}

# Iterate over all folders under ../middleware. These folder names reflect the namespace of where each component (sub-folder of this folder) will be deployed. Apply helm template for each component and apply the resulting yaml file to the corresponding namespace.
_deploy_middleware() {
    for dir in ../middleware/*; do
        namespace=$(basename $dir)
        for component in $dir/*; do
            helm dependency update $component
            helm template $component -n $namespace | kubectl apply -f $component.yml -n $namespace
            rm -rf $dir.yml
        done
    done
}

# Template the ../backend folder and apply the resulting yaml file to the development namespace
_deploy_backend() {
    helm template ../backend --namespace development | kubectl apply -f - -n development
}

# Create necessary secrets for components (ghcr-secret for access to tumble-for-kronox packages, tumble-backend-secrets which contains AWS stuff, JWT stuff, dbconnection stuff). The ghcr token must be passed as an argument to this script and the dotnet secrets must be in a file called tumble-backend-secrets.json whose location is passed as an argument to this script.
_create_secrets() {
    ghcr_token=$1
    secrets_file=$2

    kubectl create secret docker-registry ghcr-secret --docker-server=ghcr.io --docker-username=tumble-for-kronox --docker-password=$ghcr_token
    kubectl create secret generic tumble-backend-secrets --from-file=$secrets_file
}

# Main
_initialize
_create_secrets
_deploy_middleware
_deploy_backend
