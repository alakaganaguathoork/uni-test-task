#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

###
# This is a general helper script to be sourced in the ../main.sh
###


###
# GENERAL
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