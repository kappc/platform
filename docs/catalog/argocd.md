# Argo CD Catalog Application

- [Argo CD Catalog Application](#argo-cd-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `argocd` catalog chart deploys the Argo CD GitOps control plane. It reconciles declarative Kubernetes manifests from Git repositories against cluster state, providing automated deployments, continuous drift detection, progressive synchronization, and RBAC-controlled access.

## Architecture

The chart packages the upstream Argo CD Helm chart with opinionated platform defaults:

- **Progressive Syncs**: Enables `applicationsetcontroller.enable.progressive.syncs: "true"` to power multi-step `RollingSync` strategies in `ApplicationSet` resources.
- **NetworkPolicy Hardening**: Disables global NetworkPolicies because the chart defaults block kubelet health probes in Cilium-based clusters; policies stay enabled for Dex, notifications, and Redis. The application controller and repo server have no ingress isolation.

## Dependencies

- **Upstream Chart**: `argo-cd`, pinned in [Chart.yaml](../../kubernetes/catalog/argocd/Chart.yaml).

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/argocd/values.schema.json) and [values.yaml](../../kubernetes/catalog/argocd/values.yaml).

Key configuration parameters:

- `argo-cd.configs.params.applicationsetcontroller.enable.progressive.syncs`: Enables progressive sync support for `ApplicationSet` `RollingSync` stages.
- `argo-cd.global.networkPolicy.create`: Disabled globally to allow Cilium CNI health probe resolution, with granular policies retained on Dex, notifications, and Redis.

## Setup

Install Argo CD with Helm during the cluster bootstrap, then let it adopt itself through an instance descriptor in the `argocd` project. Follow the bootstrap runbook of the target cluster listed in the [Clusters Documentation](../clusters/README.md#cluster-inventory).
