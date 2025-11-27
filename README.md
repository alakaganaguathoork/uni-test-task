# Objective

This is a test task project for Spam2000 app infrastucture setup. It aim is to test skills of a newcommer in DevOps field.

The `main.sh` will install few required packages (based on OS: Linux/MacOS), tools and run services as ArgoCD applications.

<span style="color: red; font-size: 22px; font-weight: 800;">! </span> Warning: This scripts uses `sudo`:

* to install required package/s and tools if they are not presented in a system;
* to append hosts in `etc/hosts` file in order to access services via domain names locally.

(minikube ran on docker driver in rootless, so no `sudo` is required for that)

<span style="color: red; font-size: 22px; font-weight: 800;">! </span> Warning: `~/.kube/config` file won't be deleted on cluster deletion (it's commented out at [./scripts/resolve_tools.sh:166](./scripts/resolve_tools.sh#L166-L168))

<span style="color: red; font-size: 22px; font-weight: 800;">! </span> Warning: Installed tools won't be deleted on cluster deletion (it's commented out in [main.sh:104](./main.sh#L104-L106))

---

Required packages to be installed (if not presented in a system):

* curl

Tools to be installed (if not installed already):

* minikube
* kubectl
* helm
* argocd (via helm)

Apps to be installed and synced in ArgoCD:

* Spam2000 app
* VictoriaMetrics (single server)
* Grafana

## Prerequisites

* Docker installed on your machine - as it's used as a container runtime for minikube.

## Notes

1. Running the `main.sh` in _VSCode terminal_ may lead to issues with file permissions. It is recommended to run the script in a standard terminal:

    ```bash
    sudo: The "no new privileges" flag is set, which prevents sudo from running as root.
    sudo: If sudo is running in a container, you may need to adjust the container configuration to disable the flag.
    ```

2. VictoriaMetrics doesn't have ingress as all metrics are pulled by Grafana from inside the cluster.
