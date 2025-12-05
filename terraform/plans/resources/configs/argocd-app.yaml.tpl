apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${name}
  namespace: argocd
  # https://github.com/argoproj/argo-cd/issues/21035#issuecomment-2828348695
  finalizers:
    # - resources-finalizer.argocd.argoproj.io
    - resources-finalizer.argocd.argoproj.io/foreground
spec:
  project: ${project}
  source:
    repoURL: https://github.com/alakaganaguathoork/uni-test-task.git
    targetRevision: main-terra
    path: charts/${name}
    helm:
      valueFiles:
        - values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: ${namespace}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
    retry:
      limit: 3
