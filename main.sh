#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'
DIR=$(dirname $0)

###
# This script automates installation of required tools and starts a local kubernetes with minikube. 
# Usage: main.sh --action <install|uninstall>
###


###
# HELPERS
###
source "$DIR/helpers/general.sh"
source "$DIR/helpers/resolve_tools.sh"

###
# PARSE ARGS
###
parse_args() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --action|-a) 
                if [[ "$#" -ge 2 && -n "$2" && "$2" != -* ]]; then
                    ACTION="${2:-}"; 
                    shift 2
                    color "Performing infrastructure $ACTION...\n"   
                    color "************************************************"
                else
                    error "You didn't pass the --action value."
                fi
                ;;
            -h|--help)
                help
                ;;
            *)
                error "Unknown argument: $1"
                ;;
        esac
  done
}

###
# DEFAULTS
###
ACTION=""
OS=$(get_os)
ARCH=$(get_arch)
REQ_PKGS=($(yq '.tools.[]' describe.yml))
# APT_PKGS=($(yq '.tools.apt[] | keys | .[]' describe.yml))
K8S_VER="1.34.0"
PROFILE="minikube-mine"
NAMESPACE="default"

###
# Functions
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
            --kubernetes-version="v$k8s_ver" 
            # --network=$NETWORK_NAME \
            # --nodes=3 \
            # --addons=$MK_ADDONS_LIST \
        
        color "Cluster $profile was started."
    else
        color "Cluster $profile already has been started."
    fi
}

delete_cluster() {
    local profile=${1:-"minikube-test"}

    if ! minikube status --profile $profile > /dev/null 2>&1; then
        error "Cluster $profile doesn't exist"
    fi

    minikube delete --profile="$profile"
    color "Cluster $profile was deleted."
}

helm_install_release() {
    local namespace=$1
    local release=$2
    local repo=$3
    local url=${4:-}
    local values=$5

    if ! helm repo list | grep "$repo"; then
        color "There is no $repo locally, adding from $url..."
        helm repo add "$repo" "$url"
        hel repo update
    fi

    if is_release_installed "$namespace" "$release"; then
        color "$release release in $namespace namespace is already installed, skipping..."
        exit 0
    fi

    helm upgrade \
        -n $namespace \
        --create-namespace \
        --install "$release" "$repo" \
        --reuse-values \
        --values "$values"
}

helm_uninstall_release() {
    local namespace=$1
    local release=$2
    helm uninstall -n "$namespace" "$release" || true
}


###
# MAIN LOGIC
###
parse_args "$@"
echo "${REQ_PKGS[@]}"

case "$ACTION" in
    install)
        color "OS: $OS"
        color "ARCH: $ARCH"
        color "Kubernetes version: $K8S_VER"

        install_required_packages "${REQ_PKGS[*]}" "$OS" "$ARCH" "$K8S_VER"
        start_cluster $PROFILE
        # helm_install_release $NAMESPACE argocd
        ;;
    destroy)
        delete_cluster $PROFILE
        uninstall_required_packages "${REQ_PKGS[*]}" "$OS"

        ;;
    *)
        error "Unknown action: $ACTION"
        ;;
esac