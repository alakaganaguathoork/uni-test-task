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
PROFILE="uni"
MK_ADDONS_LIST="ingress,volumesnapshots"


###
# MAIN LOGIC
###
parse_args "$@"

case "$ACTION" in
    install)
        # this block assures all required tools and services are installed before proceeding to applications
        {
            install_required_pkgs "${REQ_PKGS[*]}" "$OS"
            install_tools "${TOOLS[*]}" "$OS" "$ARCH" "$K8S_VER"
            start_cluster $PROFILE
            install_service_via_helm "argocd" "argocd" "argo" "argo/argo-cd" "https://argoproj.github.io/argo-helm" "$DIR/values-files/argocd.yml"
        }

        # application
        create_argocd_app spam 
        create_argocd_app vmstack

        # debug
        {
            color "OS: $OS"
            color "ARCH: $ARCH"
            color "Kubernetes version: $K8S_VER"
            color "Required packages installed:\n${REQ_PKGS[*]}"
            color "Tools installed:\n${TOOLS[*]}"
            sleep 5
            get_argocd_password
        }
        color "Done creation."
        ;;
    destroy)
        delete_cluster $PROFILE
        uninstall_tools "${TOOLS[*]}" "$OS"
        uninstall_required_pkgs "${REQ_PKGS[*]}" "$OS"

        # Debug
        {   
            color "These packages were NOT purged (to not break your system):\n${REQ_PKGS[*]}"
            color "Tools deleted:\n${TOOLS[*]}"
        }
        color "Done destruction."
        ;;
    *)
        error "Unknown action: $ACTION"
        ;;
esac
