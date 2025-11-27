#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

###
# This is a helper script to install all required packages & tools, and to be sourced in the ../main.sh
###


###
# PACKAGES
###
install_required_pkgs() {
    local pkgs=$1 
    local os="$2"

    for package in $pkgs; do
        install_pkg $os $package
    done
}

uninstall_required_pkgs() {
    local pkgs=$1 
    local os="$2"

    for package in $pkgs; do
        uninstall_pkg $os $package
    done
}

install_pkg() {
    local os="$1"
    local pkg="$2"
    local repo="${3-}"

    case $os in
        linux)
            if ! dpkg -s $pkg > /dev/null 2>&1; then
                color "Installing a required missing package $pkg with apt..."
                if [[ -n $repo ]]; then 
                    sudo add-apt-repository $repo
                    sudo apt update
                fi
                
                sudo apt install $pkg -y 
            else
                color "Package $pkg already installed, skipping..."
            fi
            ;;
        darwin)
            if ! command -v brew >/dev/null 2>&1; then
                error "Homebrew is not installed. Install it from https://brew.sh first."
                return 1
            elif ! brew list | grep $pkg > /dev/null 2>&1; then
                color "Installing misshing package $pkg with brew..." 
                brew install $pkg
            else
                color "Package $pkg already installed, skipping..."
            fi
            ;;
        *)
            error "Unsupported OS: $os."
            ;;
    esac
}

uninstall_pkg() {
    local os="$1"
    local pkg="$2"
    local repo="${3:-}"

    case $os in
        linux)
            if ! dpkg -s $pkg > /dev/null 2>&1; then
                color "There is no package $pkg, skipping..."
            else
                color "Unnstalling package $pkg with apt..."
                sudo apt purge $pkg -y
                if [[ -n $repo ]]; then
                    sudo add-apt-repository --remove $repo
                fi
            fi
            ;;
        darwin)
            if ! brew list | grep $pkg > /dev/null 2>&1; then
                color "There is no package $pkg, skipping..."
            else
                color "Unnstalling package $pkg with brew..."
                brew uninstall $pkg
            fi
            ;;
        *)
            error "Unsupported OS: $os."
    esac
}

install_tools() {
    local tools=$1
    local os=$2
    local arch=$3
    local k8s_ver=${4:-}

    for tool in $tools; do
        color "Checking $tool..."
        if ! command -v "$tool" > /dev/null 2>&1; then
            color "Installing $tool..."
            install_"$tool" $os $arch $k8s_ver
        else
            color "$tool is already installed."
        fi
    done

    color "All required tools were installed."
}

uninstall_tools() {
    local tools=$1
    local os=${2:-}

    for tool in $tools; do
        color "Checking $tool..."
        if command -v "$tool" > /dev/null 2>&1; then
            color "Uninstalling $tool..."
            uninstall_"$tool" $os
        else
            color "$tool is not installed."
        fi
    done

    color "All required packages were uninstalled."

}

###
# TOOLS
###
install_minikube() {
    local os=$1
    local arch=$2

    curl -LO "https://github.com/kubernetes/minikube/releases/latest/download/minikube-$os-$arch"
    sudo install "minikube-$os-$arch" /usr/local/bin/minikube
    rm "minikube-$os-$arch"
}

uninstall_minikube() {
    sudo rm "$(command -v minikube)"
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
    sudo rm "$(command -v kubectl)"
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
    sudo rm -rf "$(command -v helm)"
    rm -rf ~/.helm
    rm -rf ~/.cache/helm
    rm -rf ~/.config/helm
    rm -rf ~/.local/share/helm
}