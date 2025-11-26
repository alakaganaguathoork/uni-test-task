#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

###
# This is a functions-containing script to be sourced in the ../main.sh
###


###
# MINIKUBE
###
start_cluster() {
    local profile=${1:="minikube-test"}
    local driver=${2:-"kvm2"}
    local c_runtime=${3:-"docker"}
    local k8s_ver=${4:-"$K8S_VER"}

    if ! is_cluster_existing; then
        minikube start \
            --profile="$profile" \
            --driver="$driver" \
            --container-runtime="$c_runtime" \
            --kubernetes-version="v$k8s_ver" \
            --addons=$MK_ADDONS_LIST
            # --network=$NETWORK_NAME \
            # --nodes=3 \
        
        color "Cluster $profile was started."
    else
        color "Cluster $profile already has been started."
    fi

    get_cluster_ip $profile
}

delete_cluster() {
    local profile=${1:-"minikube-test"}

    if ! minikube status --profile $profile > /dev/null 2>&1; then
        error "Cluster $profile doesn't exist"
    fi

    minikube delete --profile="$profile"
    color "Cluster $profile was deleted."
}

get_cluster_ip() {
    local profile=$1
    if ! is_cluster_existing; then
        color "Cluster doesn't exist yet."
        exit 0
    fi

    color "Cluster IP: $(minikube ip -p $profile)"
}

get_argocd_password() {
    local com="$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"
    color "ArgoCD initial password: ${com}"
}


###
# HELM
###
install_service_via_helm() {
    local namespace=$1
    local name=$2
    local repo=$3
    local release=$4
    local url=${5:-}
    local values=$6

    if ! helm repo list | grep "$repo" > /dev/null 2>&1; then
        color "There is no $repo locally, adding from $url..."
        helm repo add "$repo" "$url"
        helm repo update
    fi

    if is_release_installed "$namespace" "$name"; then
        color "$name release in $namespace namespace is already installed, skipping..."
        exit 0
    fi

    helm upgrade \
        -n $namespace \
        --create-namespace \
        --install "$name" "$release" \
        --reuse-values \
        --values "$values"
}

uninstall_service_via_helm() {
    local namespace=$1
    local release=$2
    helm uninstall -n "$namespace" "$release" || true
}