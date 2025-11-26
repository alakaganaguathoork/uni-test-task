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
# Functions
###
source "$DIR/helpers/functions.sh"


###
# DEFAULTS
###
ACTION=""
OS=$(get_os)
ARCH=$(get_arch)
REQ_PKGS=(wget curl)
TOOLS=(minikube kubectl helm)
K8S_VER="1.34.0"
PROFILE="minikube-mine"
MK_ADDONS_LIST="ingress,volumesnapshots"


###
# MAIN LOGIC
###
parse_args "$@"

case "$ACTION" in
    install)
        install_required_pkgs "${REQ_PKGS[*]}" "$OS"
        install_tools "${TOOLS[*]}" "$OS" "$ARCH" "$K8S_VER"
        start_cluster $PROFILE
        install_service_via_helm "argocd" "argocd" "argo" "argo/argo-cd" "https://argoproj.github.io/argo-helm" "$DIR/values-files/argocd.yml"

        color "OS: $OS"
        color "ARCH: $ARCH"
        color "Kubernetes version: $K8S_VER"
        color "Required packages installed: ${REQ_PKGS[*]}"
        color "Tools installed: ${TOOLS[*]}"
        # get_cluster_ip $PROFILE
        get_argocd_password

        kubectl apply -f helm/applications/spam.yml
        kubectl apply -f helm/applications/vmstack.yml
        ;;
    destroy)
        delete_cluster $PROFILE
        uninstall_tools "${TOOLS[*]}" "$OS"
        # uninstall_required_pkgs "${REQ_PKGS[*]}" "$OS"

        color "OS: $OS"
        color "ARCH: $ARCH"
        color "Kubernetes version: $K8S_VER"
        color "These packages were NOT purged (to not break your system): ${REQ_PKGS[*]}"
        color "Tools deleted: ${TOOLS[*]}"
        # color "Services deleted: $SERVICES"
        ;;
    *)
        error "Unknown action: $ACTION"
        ;;
esac

        get_cluster_ip $PROFILE
        get_argocd_password