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
source "$DIR/scripts/general.sh"
source "$DIR/scripts/resolve_tools.sh"

###
# PARSE ARGS
###
parse_args() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --action) 
                if [[ "$#" -ge 2 && -n "$2" && "$2" != -* ]]; then
                    ACTION="${2:-}"; 
                    shift 2
                    color "Performing infrastructure $ACTION...\n"   
                    color "************************************************"
                else
                    error "You didn't pass the --action value."
                fi
                ;;
            --help)
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
source "$DIR/scripts/functions.sh"


###
# DEFAULTS
###
ACTION=""
OS=$(get_os)
ARCH=$(get_arch)
REQ_PKGS=(curl)
TOOLS=(minikube kubectl helm)
K8S_VER="1.34.0"
PROFILE="uni"
MK_ADDONS_LIST="ingress"
# APPS=("spam" "vmstack" "argocd")


###
# MAIN LOGIC
###
parse_args "$@"

case "$ACTION" in
    install)
        install_required_pkgs "${REQ_PKGS[*]}" "$OS"
        install_tools "${TOOLS[*]}" "$OS" "$ARCH" "$K8S_VER"
        start_cluster $PROFILE
        bootstrap_argocd "$DIR/argocd-bootstrap-values.yml"

        # separate Application(s)
        # {
            # for app in "${APPS[@]}"; do
                # create_argocd_app "$app" 
            # done
        # }

        # Project + ApplicationSet
        kubectl_apply "$DIR/argocd-project.yaml"
        kubectl_apply "$DIR/argocd-apps-set.yaml"
        
        # debug
        print_stat
        color "Done creation."
        ;;
    destroy)
        delete_cluster $PROFILE
        # uninstall_tools "${TOOLS[*]}" "$OS"       # uncomment in order to delete installed tools
        # uninstall_required_pkgs "${REQ_PKGS[*]}" "$OS"    # as curl potentially was installed before, do not purge it from user's system

        # Debug
        color "These packages were NOT purged (to not break your system):"
        echo "${REQ_PKGS[*]}"
        color "These tools were NOT deleted (commented out for now):"
        echo "${TOOLS[*]}"
        color "Done destruction."
        ;;
    *)
        error "Unknown action: $ACTION"
        ;;
esac
