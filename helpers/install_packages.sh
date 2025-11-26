#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

###
# This is a helper script to be sourced in the ../main.sh
###


###
# MAIN
###
install_via_pkg_manager() {
    local os="$1"
    local tool="$2"
    local repo="${3-}"

    case $os in
        linux)
            if ! dpkg $tool > /dev/null 2>&1; then
                color "Installing missing packages $tool with apt..."
                if [[ -n $repo ]]; then 
                    sudo add-apt-repository $repo
                fi
                # sudo apt update
                sudo apt install $tool -y 
            fi
            ;;
        darwin)
            if ! command -v brew >/dev/null 2>&1; then
                error "Homebrew is not installed. Install it from https://brew.sh first."
                return 1
            elif ! brew list | grep $tool > /dev/null 2>&1; then
                color "Installing misshing package $tool with brew..." 
                brew install $tool
            fi
            ;;
        *)
            error "Unsupported OS: $os."
            ;;
    esac
}

uninstall_via_pkg_manager() {
    local os="$1"
    local tool="$2"
    local repo="${3:-}"

    case $os in
        linux)
            color "Installing package $tool with apt..."
            sudo apt purge $tool -y
            if [[ -n $repo ]]; then
                sudo add-apt-repository --remove $repo
            fi
            ;;
        darwin)
            if brew list | grep $tool > /dev/null 2>&1; then
                brew uninstall $tool
            fi
            ;;
        *)
            error "Unsupported OS: $os."
    esac
}

install_required_packages() {
    local pkgs=$1
    local os=$2
    local arch=$3
    local k8s_ver=${4:-}

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
    local os=${2:-}

    for package in $pkgs; do
        color "Checking $package..."
        if command -v "$package" > /dev/null 2>&1; then
            color "Uninstalling $package..."
            uninstall_"$package" $os
        else
            color "$package is not installed."
        fi
    done

    color "All required packages were uninstalled."

}

###
# INSTALLS
###
install_curl() {
    local os=$1

    install_via_pkg_manager "$os" curl
}

uninstall_curl() {
    local os=$1

    uninstall_via_pkg_manager "$os" curl
}

install_wget() {
    local os=$1

    install_via_pkg_manager "$os" wget
}

uninstall_wget() {
    local os=$1

    uninstall_via_pkg_manager "$os" wget
}

install_minikube() {
    local os=$1
    local arch=$2

    curl -LO "https://github.com/kubernetes/minikube/releases/latest/download/minikube-$os-$arch"
    sudo install "minikube-$os-$arch" /usr/local/bin/minikube
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

install_helm() {
    curl -fsSL "https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3" -o get_helm.sh 
    chmod 700 get_helm.sh
    ./get_helm.sh
    rm get_helm.sh
}

uninstall_helm() {
    sudo rm -rf "$(which helm)"
    rm -rf ~/.helm
    rm -rf ~/.cache/helm
    rm -rf ~/.config/helm
    rm -rf ~/.local/share/helm
}

install_yq() {
    local os=$1
    local arch=$2

    case $os in
        linux)
            wget "https://github.com/mikefarah/yq/releases/download/lates/yq_$arch" -O yq 
            chmod +x yq && mv yq /usr/local/bin/yq
            ;;
        darwin)
            brew install yq
            ;;
        *)
            error "Unsupported OS: $os."
            ;;
    esac
}

uninstall_yq() {
    local $os="$1"

    case $os in
        linux)
            sudo rm -rf "$(which yq)"
            ;;
        darwin)
            brew uninstall yq
            ;;
        *)
            error "Unsupported OS: $os."
            ;;
    esac
}

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