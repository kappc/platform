# Cilium Catalog Application

- [Cilium Catalog Application](#cilium-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `cilium` catalog chart installs the Cilium Container Network Interface (CNI). Powered by eBPF, Cilium provides transparent network connectivity, advanced security filtering, service load balancing, and observability for Kubernetes pods.

## Architecture

The chart vendors the upstream Cilium Helm chart for clusters that keep `kube-proxy`:

- **Co-existence with kube-proxy**: Sets `kubeProxyReplacement: false` and `bpf.masquerade: false`, so Cilium provides pod networking while `kube-proxy` keeps handling Services.
- **Idempotency Protection**: Cilium's Helm templates generate secrets that change on every render. Instances set `argocd.ignoreDifferences` for secrets labeled `cilium.io/helm-template-non-idempotent` to avoid false sync drift.

## Dependencies

- **Upstream Chart**: `cilium`, pinned in [Chart.yaml](../../kubernetes/catalog/cilium/Chart.yaml).

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/cilium/values.schema.json) and [values.yaml](../../kubernetes/catalog/cilium/values.yaml).

Key configuration parameters:

- `cilium.kubeProxyReplacement` and `cilium.bpf.masquerade`: Disabled so Cilium co-exists with `kube-proxy`.
- `cilium.routingMode` and `cilium.ipv4NativeRoutingCIDR`: Set in instance values to match the cluster's pod network.
- `cilium.k8sServiceHost` and `cilium.k8sServicePort`: Set in instance values to the Kubernetes API endpoint.

## Setup

Cilium provides the CNI, so install it with Helm before Argo CD and let it adopt itself through an instance descriptor afterwards:

```sh
helm dependency build kubernetes/catalog/cilium
helm upgrade --install cilium kubernetes/catalog/cilium \
  --namespace kube-system \
  -f kubernetes/clusters/<CLUSTER>/instances/cilium/values.yaml
kubectl -n kube-system exec ds/cilium -- cilium-dbg status
```
