# Objective

This is a test task project for Spam2000 app infrastucture setup. It aim is to test skills of a newcommer in DevOps field.

The `main.sh` will install few required packages (based on OS: Linux/potentially, MacOS - I didn't have a device available to test, but required package/s installation has conditional logic for `os` and `arch` in [./scripts/general.sh](./scripts/general.sh)), tools and run services as ArgoCD applications.

## Condiderations

:warning: **Warning**: This scripts uses `sudo`:

* to install required package/s and tools if they are not presented in a system;
* to append hosts in `etc/hosts` file in order to access services via domain names locally.

(minikube ran on docker driver in rootless, so no `sudo` is required for that)

:warning: **Warning**: `~/.kube/config` file won't be deleted on cluster deletion (it's commented at [./scripts/resolve_tools.sh:166](./scripts/resolve_tools.sh#L166))

:warning: **Warning**: Installed tools won't be deleted on cluster deletion (it's commented in [main.sh:104](./main.sh#L104))

## Prerequisites

* Docker installed on your machine - as it's used as a container runtime for minikube.

## Usage

To run the project, execute the following command in your terminal:

```bash
./main.sh --action <install|destroy>
```

To access the services, follow this table:

| Service        | URL                             | Username / Password (if applicable)                        |
|----------------|---------------------------------|------------------------------------------------------------|
| ArgoCD         | http://argocd.uni.local         | admin / initial pass would be printed in command terminal  |
| Spam2000 app   | http://spam2000.uni.local       | -                                                          |
| Grafana        | http://grafana.uni.local        | admin / grafana                                            |
| VictoriaMetrics| http://vm.uni.local             | -                                                          |

## What will be installed

Required packages to be installed (if not presented in a system):

* curl

Tools to be installed (if not installed already):

* minikube
* kubectl
* helm
* argocd (via helm)

Apps to be installed and synced in ArgoCD:

* spam2000
* victoria-metrics-single
* kube-state-metrics
* prometheus-node-exporter
* grafana

## Notes

1. Running the `main.sh` in _VSCode terminal_ may lead to issues with file permissions. It is recommended to run the script in a standard terminal:

    ```bash
    sudo: The "no new privileges" flag is set, which prevents sudo from running as root.
    sudo: If sudo is running in a container, you may need to adjust the container configuration to disable the flag.
    ```

2. Cluster will be created with such params in [./scripts/functions.sh:L85-92](./scripts/functions.sh#L85-92):

    ```bash
    --profile="uni" \
    --driver="kvm2" \
    --memory="4096" \
    --cpus="2" \
    --container-runtime="docker" \
    --kubernetes-version="v1.34.0" \
    --addons="ingress"
    ```

3. `max_scrape_size` was increased in order to overcome too 'noisy' spam2000 app [./helm/charts/vmstack/values.yaml:35](./helm/charts/vmstack/values.yaml#L35)

4. Few lables were dropped from `random_gauge_1` metric to make it less cardinal in job `spam` [./helm/charts/vmstack/values.yaml:37-39](./helm/charts/vmstack/values.yaml#L37-39)
