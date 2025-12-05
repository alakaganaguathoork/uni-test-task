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


###
# HOST
###
edit_hosts_file() {
    local action=$1
    local minikube_ip="$2"
    local record="$minikube_ip  argocd.uni.local grafana.uni.local spam2000.uni.local vm.uni.local"

    case $action in
        add)
            if grep -Fxq "$record" /etc/hosts; then
                echo "Exact line already present" > /dev/null
            else
            color "Adding cluster hosts to the /etc/hosts file"
            sudo tee -a /etc/hosts <<EOF
$record
EOF
            fi
            ;;
        remove)
            if grep -Fxq "$record" /etc/hosts; then
                color "Removing cluster hosts from /etc/hosts file"
                sudo sed -i "/$minikube_ip/d" /etc/hosts
            fi
            ;;
        *)
            error "No action was provided for edit_hosts_file()"
            ;;
    esac
}

get_cluster_ip() {
    local profile=$1
    if ! is_cluster_existing; then
        color "Cluster doesn't exist yet, so cluster IP can't be retrieved."
    else
        echo "$(minikube ip -p $profile)"
    fi
}

get_argocd_password() {
    local com=""
    
    com=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' 2>/dev/null | base64 -d || true)
    # echo "ArgoCD password: $com" >> $DIR/info.txt
    color "ArgoCD initial password: ${com}"
}

###
# TERRAFORM
###
tf_apply() {
    local plans="$1"
    for plan in $plans; do
        cd "$DIR/terraform/plans/${plan}"
        terraform fmt
        terraform init
        terraform apply --auto-approve
        color "Finished 'apply' for $plan."
        cd - > /dev/null
    done
}

tf_destroy() {
    local plans="$1"
    local os="$2"
    local tool=""

    case $os in
        linux)
            tool="tac"
            ;;
        darwin)
            tool="gtac"
            ;;
        *)
            error "OS is not supported: $os"
            ;;
    esac

    while read -r plan; do
        cd "$DIR/terraform/plans/${plan}"
        terraform destroy --auto-approve
        color "Finished 'destroy' for $plan."
        cd - >/dev/null
    done < <(printf "%s\n" $plans | $tool)
}
