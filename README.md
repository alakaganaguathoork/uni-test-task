# Objective

This is a test task project for Spam2000 app infrastucture setup. It aim is to test skills of a newcommer in DevOps field.

The `main.sh` will install few required packages (based on OS: Linux/MacOS), tools and run services as ArgoCD applications.

Required packages to be installed (if not presented in a system):

* wget
* curl

Tools to be installed (if not installed already):

* minikube
* kubectl
* helm
* argocd (via helm)

Apps to be installed and synced in ArgoCD:

* Spam2000 app
* VictoriaMetrics
* Grafana

## Prerequisites

* Docker installed on your machine.

## Notes

1. Running the `main.sh` in _VSCode terminal_ may lead to issues with file permissions:

    ```bash
    sudo: The "no new privileges" flag is set, which prevents sudo from running as root.
    sudo: If sudo is running in a container, you may need to adjust the container configuration to disable the flag.
    ```

It is recommended to run the script in a standard terminal.

```bash
docker pull andriiuni/spam2000:1.1394.355
```
