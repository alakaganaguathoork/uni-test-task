#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

###
# This script automates installation of required tools and starts a local kubernetes with minikube. 
# Usage: main.sh --action <install|uninstall>
###


###
# HELPERS
###
color() {
  printf "\e[1;35m%b\e[0m\n" "$1"    # bold magenta
}

error() {
    printf "\e[1;31m%b\e[0m\n" "$1" 1>&2
    exit 1
}

help() {
    local help_string=$(cat <<EOF
This script automates < > based on provided argument/s --.
Usage: main.sh --action <install|destroy>
EOF
) 
    color "$help_string"
    exit 0
}

get_os() {
    local os=""
    os=$(uname)
    # os="Darwin"
    # os="Win"

    if [[ $os == "Linux" ]]; then
        echo "linux"
        # return 0
    elif [[ $os == "Darwin" ]]; then
        echo "darwin"
        # return 0
    else
        error "Sorry, this script was designed to run on Debian-based systems (Debian, Ubuntu, Mint) or MacOS."
    fi
}

get_arch() {
    local arch=""
    arch=$(uname -m)
    # arch="test"

    case $arch in
        x86_64|amd64)
            arch="amd64"
        ;;
        arm64)
            arch="arm64"
        ;;
        *)
            error "Sorry, this script was designed to process packages installation in arm64 or amd64 architectures."
        ;;
    esac

    echo $arch
}

check_pkg_manager() {
    local os=$1
    
    case $os in
        linux)
            color "Installing missing required packages with apt."
            return 0
            ;;
        darwin)
            if ! command -v brew >/dev/null 2>&1; then
                error "Homebrew is not installed. Install it from https://brew.sh first."
                return 1
            fi
            # brew install $*"
            return 0
            ;;
        *)
            error "Unsupported OS $os"
            ;;
    esac
}

install_minikube() {
    local os=$1
    local arch=$2

    curl -LO "https://github.com/kubernetes/minikube/releases/latest/download/minikube-$os-$arch"
    sudo install minikube-$os-$arch /usr/local/bin/minikube
    rm "minikube-$os-$arch"
}

uninstall_minikube() {
    sudo rm "$(which minikube)"
    rm -rf ~/.minikube
    color "minikube was uninstalled from the system."
}

install_kubectl() {
    local os=$1
    local arch=$2
    local ver="v$3"
    echo "https://dl.k8s.io/release/$ver/bin/$os/$arch/kubectl"
    curl -LO "https://dl.k8s.io/release/$ver/bin/$os/$arch/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
}

uninstall_kubectl() {
    sudo rm "$(which kubectl)"
    # rm -rf ~/.kube
    color "kubectl was uninstalled from the system."
}

install_required_packages() {
    local pkgs=$1
    local os=$2
    local arch=$3
    local k8s_ver=$4

    check_pkg_manager "$os"
    # install_minikube "$os" "$arch"

    for package in $pkgs; do
        color "Checking $package..."
        if ! command -v "$package" > /dev/null 2>&1; then
            color "Installing $package..."
            install_"$package" $os $arch $k8s_ver
        else
            color "$package is already installed."
        fi
    done

    color "All required packages were installed."
}

uninstall_required_packages() {
    local pkgs=$1

    for package in $pkgs; do
        color "Checking $package..."
        if command -v "$package" > /dev/null 2>&1; then
            color "Uninstalling $package..."
            uninstall_"$package"
        else
            color "$package is not installed."
        fi
    done

    color "All required packages were uninstalled."

}

is_cluster_existing() {
    kubectl cluster-info >/dev/null 2>&1
}

is_release_installed() {
    helm status -n "$NAMESPACE" "$1" >/dev/null 2>&1
}

create_cluster() {
    color "Starting minikube cluster from a sourced custom script..."
    source <(curl -S "https://raw.githubusercontent.com/alakaganaguathoork/local-business-open-api-project/refs/heads/main/minikube.sh")
}


###
# DEFAULTS
###
ACTION=""
OS=$(get_os)
ARCH=$(get_arch)
REQ_PKGS=(minikube kubectl)
K8S_VER="1.34.0"
PROFILE="minikube-mine"
NAMESPACE="default"

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
start_cluster() {
    local profile=${1:="minikube-test"}
    local driver=${2:-"kvm2"}
    local c_runtime=${3:-"docker"}
    local k8s_ver=${4:-"$K8S_VER"}

    minikube start \
        --profile="$profile" \
        --driver="$driver" \
        --container-runtime="$c_runtime" \
        --kubernetes-version="v$k8s_ver" 
        # --network=$NETWORK_NAME \
        # --nodes=3 \
        # --addons=$MK_ADDONS_LIST \
    
    color "Cluster $profile was started."
}

delete_cluster() {
    local profile=${1:-"minikube-test"}

    if ! minikube status --profile $profile > /dev/null 2>&1; then
        error "Cluster $profile doesn't exist"
    fi

    minikube delete --profile="$profile"
    color "Cluster $profile was deleted."
}


###
# MAIN LOGIC
###
parse_args "$@"

case "$ACTION" in
    install)
        color "OS: $OS"
        color "ARCH: $ARCH"
        color "Kubernetes version: $K8S_VER"

        install_required_packages "${REQ_PKGS[*]}" "$OS" "$ARCH" "$K8S_VER"
        start_cluster $PROFILE
        ;;
    destroy)
        delete_cluster $PROFILE
        uninstall_required_packages "${REQ_PKGS[*]}"

        ;;
    *)
        error "Unknown action: $ACTION"
        ;;
esac