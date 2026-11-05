# Loki Catalog Application

- [Loki Catalog Application](#loki-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `loki` catalog chart deploys Grafana Loki, a horizontally scalable, highly available, multi-tenant log aggregation system. The platform packages Loki in `SingleBinary` mode with local filesystem storage and TSDB index schema, providing a lightweight log store tailored for homelab clusters and development environments.

## Architecture

The chart vendors the upstream Grafana Loki Helm chart with customized platform templates:

- **Deployment Mode**: Loki runs as a single-binary `StatefulSet` with persistent volume storage for log chunks and the TSDB index.
- **Gateway**: The built-in NGINX gateway provides a unified reverse proxy endpoint for log ingestion and query APIs on port `80`.
- **Gateway API Ingress**: An `HTTPRoute` exposes the Loki gateway through the shared Envoy Gateway.
- **Network Isolation**: By default, network policies can be handled within the target namespace or enabled via the network policy template.

## Dependencies

- **Upstream Chart**: `loki`, pinned in [Chart.yaml](../../kubernetes/catalog/loki/Chart.yaml).

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/loki/values.schema.json) and [values.yaml](../../kubernetes/catalog/loki/values.yaml).

Key configuration parameters:

- `loki.deploymentMode`: Set to `SingleBinary` to run all Loki components in a single pod.
- `loki.singleBinary.persistence.size`: Storage capacity for log chunks and the TSDB index (default `10Gi`).
- `loki.loki.storage.type`: Set to `filesystem` for local volume-backed chunk storage without requiring external object storage.
- `httpRoute`: Set `httpRoute.hostname` in instance values.

## Setup

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `platform`.

```yaml
# kubernetes/clusters/<CLUSTER>/instances/<INSTANCE>/instance.yaml
---
application: loki
argocd:
  project: platform
  rolloutGroup: platform
namespace: monitoring
```

```yaml
# kubernetes/clusters/<CLUSTER>/instances/<INSTANCE>/values.yaml
---
global:
  domain: <DOMAIN>
```
