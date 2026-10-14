#!/usr/bin/env bash
set -euo pipefail
context="${KUBE_CONTEXT:-kind-gitops}"
delete_kind=false
while [[ $# -gt 0 ]]; do case "$1" in --context) context="$2"; shift 2;; --delete-kind) delete_kind=true; shift;; *) echo "unknown option: $1" >&2; exit 2;; esac; done
kubectl config use-context "$context"
kubectl delete application platform-root -n argocd --ignore-not-found
if [[ "$delete_kind" == true ]]; then kind delete cluster --name "${context#kind-}"; fi
echo "Removed platform-root; Crossplane claims were intentionally left untouched."
