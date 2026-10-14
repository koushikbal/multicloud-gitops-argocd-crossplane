#!/usr/bin/env bash
set -euo pipefail
context="${KUBE_CONTEXT:-kind-gitops}"
create_kind=false
while [[ $# -gt 0 ]]; do case "$1" in --context) context="$2"; shift 2;; --create-kind) create_kind=true; shift;; *) echo "unknown option: $1" >&2; exit 2;; esac; done
if [[ "$create_kind" == true ]] && ! kind get clusters 2>/dev/null | grep -qx "${context#kind-}"; then kind create cluster --name "${context#kind-}"; fi
kubectl config use-context "$context"
helm repo add argo https://argoproj.github.io/argo-helm --force-update
helm repo update
helm upgrade --install argocd argo/argo-cd --namespace argocd --create-namespace --set server.service.type=ClusterIP --wait --timeout 10m
kubectl -n argocd rollout status deployment/argocd-server --timeout=5m
echo "Argo CD is ready in context ${context}. Apply argocd/root-app.yaml after setting its repository URL."
