#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

###
# This is a functions-containing script to be sourced in the ../main.sh
###


###
# CLUSTER HELPERS
###
is_cluster_existing() {
    kubectl cluster-info >/dev/null 2>&1
}

is_release_installed() {
    local namespace=$1
    local release=$2
    helm status -n "$namespace" "$release" >/dev/null 2>&1
}


###
# MINIKUBE
###
edit_hosts_file() {
    local action=$1
    local minikube_ip="$2"

    case $action in
        add)
            color "Adding cluster hosts to the /etc/hosts file"
            sudo tee -a /etc/hosts <<EOF
$minikube_ip  argocd.mishap.local grafana.mishap.local spam200.mishap.local vm.mishap.local
EOF
            ;;
        remove)
            color "Removing cluster hosts from /etc/hosts file"
            sudo sed -i "/$minikube_ip/d" /etc/hosts            ;;
        *)
            error "No action was provided for edit_hosts_file()"
            ;;
    esac
}

get_cluster_ip() {
    local profile=$1
    if ! is_cluster_existing; then
        color "Cluster doesn't exist yet, so cluster IP can't be retrieved."
        # exit 0
    fi

    echo "$(minikube ip -p $profile)"
}

get_argocd_password() {
    local com=""

    while [[ -z "$com" ]]; do
        color "Waiting for ArgoCD password..."
        com="$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' 2>/dev/null | base64 -d || true)"
        sleep 1
    done

    color "ArgoCD initial password: ${com}"
}

start_cluster() {
    local profile=${1:="minikube-test"}
    local driver=${2:-"kvm2"}
    local c_runtime=${3:-"docker"}
    local k8s_ver=${4:-"$K8S_VER"}
    local addons=${5:-"$MK_ADDONS_LIST"}
    local cluster_ip=""

    if ! is_cluster_existing; then
        minikube start \
            --profile="$profile" \
            --driver="$driver" \
            --container-runtime="$c_runtime" \
            --kubernetes-version="v$k8s_ver" \
            --addons="$addons"
            # --network=$NETWORK_NAME \
            # --nodes=3 \
        
        color "Cluster $profile was started."
    else
        color "Cluster $profile already has been started."
    fi

    cluster_ip=$(get_cluster_ip $profile)
    edit_hosts_file add "$cluster_ip"
}

delete_cluster() {
    local profile=${1:-"minikube-test"}
    local cluster_ip=""

    if ! minikube status --profile $profile > /dev/null 2>&1; then
        error "Cluster $profile doesn't exist"
    fi

    cluster_ip=$(get_cluster_ip $profile)
    edit_hosts_file remove "$cluster_ip"
    minikube delete --profile="$profile"

    color "Cluster $profile was deleted."
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

create_argocd_app() {
    name=$1
    app_folder="$DIR/helm/applications"
    path="${app_folder}/${name}.yml"

    if [[ -z $path ]]; then
        error "Application file $path not found."
    fi

    color "$(kubectl apply -f "$path")"
}