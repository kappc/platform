# Headscale Catalog Application

- [Headscale Catalog Application](#headscale-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `headscale` catalog chart deploys Headscale, an open-source, self-hosted implementation of the Tailscale coordination server. It manages Tailnet node registration, wireguard keys, routing, and access control policies without depending on the proprietary Tailscale SaaS control plane.

## Architecture

The chart deploys Headscale as a native platform chart:

- **Control Plane Server**: Headscale runs as a hardened, single-replica `Deployment` serving client traffic on HTTP port `8080` and Prometheus metrics on port `9090`.
- **Storage**: Headscale persists node noise private keys and SQLite database state to a `PersistentVolumeClaim` at `/var/lib/headscale`. When `database.enabled` is `true`, Headscale connects to a dedicated CloudNativePG PostgreSQL cluster.
- **Gateway API Ingress**: An `HTTPRoute` exposes the Headscale coordination endpoint through the shared Envoy Gateway.
- **Network Isolation**: A `CiliumNetworkPolicy` isolates ingress traffic to the HTTP port and allows traffic from the Envoy Gateway and Kubelet probes.

## Dependencies

- **Database (Optional)**: CloudNativePG operator when PostgreSQL is enabled via `database.enabled: true`.

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/headscale/values.schema.json) and [values.yaml](../../kubernetes/catalog/headscale/values.yaml).

Key configuration parameters:

- `image`: Pinned container repository, tag, and sha256 digest for `headscale/headscale`.
- `database.enabled`: Toggles between SQLite file storage on the persistent volume (`false`, recommended) and a CloudNativePG PostgreSQL cluster (`true`).
- `persistence.size`: Storage capacity for `/var/lib/headscale` (default `5Gi`).
- `config.dns.baseDomain`: Tailnet magic DNS search domain.
- `httpRoute`: Set `httpRoute.hostname` in instance values.

## Setup

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `workload`.

```yaml
# kubernetes/clusters/<CLUSTER>/instances/<INSTANCE>/instance.yaml
---
application: headscale
argocd:
  project: workload
  rolloutGroup: workload
namespace: headscale
```

```yaml
# kubernetes/clusters/<CLUSTER>/instances/<INSTANCE>/values.yaml
---
global:
  domain: <DOMAIN>
```

When connecting a Tailscale client node to Headscale, authenticate against the public endpoint:

```sh
tailscale up --login-server https://<INSTANCE>.<DOMAIN>
```
