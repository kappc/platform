# Whoami Catalog Application

- [Whoami Catalog Application](#whoami-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `whoami` catalog chart is a native platform chart that deploys Traefik Whoami, a tiny HTTP service that outputs OS, process, network, and HTTP request headers. It serves as the primary verification tool for Gateway API routing, path matching, and header propagation across the platform.

## Architecture

As a native platform chart, Whoami adheres to all platform security standards:

- **Immutable Image**: Pins the image by tag and `@sha256:` digest.
- **Pod Security Hardening**: Runs as non-root user and group `65532` with a read-only root filesystem, no privilege escalation, all capabilities dropped, and the `RuntimeDefault` seccomp profile.
- **Gateway API Ingress**: An `HTTPRoute` from the `httpRoute` values attached to the shared Envoy Gateway.
- **Network Isolation**: A `CiliumNetworkPolicy` admits only the namespace, the node, and the gateway.
- **No API Access**: The pod does not mount a service account token.
- **Health Probes**: HTTP readiness and liveness probes on `/`.

## Dependencies

- **Chart Type**: Native platform chart without upstream dependencies.

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/whoami/values.schema.json) and [values.yaml](../../kubernetes/catalog/whoami/values.yaml).

Key configuration parameters:

- `httpRoute`: Set `httpRoute.hostname` in instance values.
- `deployment.replicas` and `resources`: Replica count and CPU and memory settings.
- `image`: Repository, tag, and `@sha256:` digest.
- `networkPolicy`: Namespace-wide `CiliumNetworkPolicy` (enabled by default, requires Cilium). `port` is the application port that the gateway and the namespaces in `allow` may reach.

## Setup

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `workload`. Verify routing through the gateway address:

```sh
curl -H "Host: <HOSTNAME>" http://<GATEWAY_ADDRESS>
```
