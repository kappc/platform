# Platform Documentation

- [Platform Documentation](#platform-documentation)
  - [Overview](#overview)
  - [Principles](#principles)
  - [Contents](#contents)

## Overview

This repository is a Kubernetes GitOps platform. Reusable Helm charts live in `kubernetes/catalog/`; cluster inventory, instance descriptors, and Argo CD configuration live in `kubernetes/clusters/<CLUSTER>/`. Argo CD reconciles every instance from Git.

## Principles

1. **Git Is the Source of Truth**: Every instance is declared by an `instance.yaml` descriptor that an `ApplicationSet` turns into an Argo CD `Application`.
1. **Pinned Artifacts**: Chart dependencies are pinned in `Chart.yaml` and `Chart.lock`, and container images by tag and `@sha256:` digest. Renovate proposes updates.
1. **Gateway API for HTTP**: Services are exposed through `HTTPRoute` resources on a shared Envoy Gateway, never through `Ingress`.
1. **Isolated Databases**: Each application that needs PostgreSQL runs its own CloudNativePG `Cluster`, protected by `Prune=confirm`.
1. **No Secrets in Git**: Secrets live in OpenBao and reach the cluster as `ExternalSecret` resources.
1. **Policy and Hardening**: Kyverno audits Pod Security Standards, resource settings, and image tags, and pods run as non-root with the `RuntimeDefault` seccomp profile.
1. **Minimal Overrides**: Cluster-specific values are limited to the instance `values.yaml` overrides that cannot be derived.

## Contents

- [Catalog Documentation](catalog/README.md): Chart types, platform patterns, and one document per catalog application.
- [Clusters Documentation](clusters/README.md): GitOps flow, instance descriptors, and one document per cluster, such as the [Homelab Cluster](clusters/homelab.md).
