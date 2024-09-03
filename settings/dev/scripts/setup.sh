# Assuming Linux/WSL/MacOS (unix-like) environment and setup kubectl, helm, and minikube

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

    # Start minikube
    minikube start --driver=docker

    # Enable ingress
    minikube addons enable ingress
}

# Iterate over all folders under ../dev/middleware, apply `helm template {folder} --values=values.yml` and `kubectl apply -f {folder}.yml`
_deploy() {
    for folder in ../dev/middleware/*; do
        if [ -d "$folder" ]; then
            helm template "$folder" $folder --values="$folder/values.yml" | kubectl apply -f $folder/$folder.yml
        fi
    done
}

