# Homer Catalog Application

- [Homer Catalog Application](#homer-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `homer` catalog chart is a native platform chart that deploys Homer, a lightweight, static dashboard designed for homelabs and personal cloud environments to provide quick navigation to all deployed services.

## Architecture

As a native platform chart, Homer implements cloud-native best practices directly in its templates:

- **Immutable Image**: Pins the image by tag and `@sha256:` digest.
- **Pod Security Hardening**: Runs as non-root user and group `1000` with a read-only root filesystem, no privilege escalation, all capabilities dropped, and the `RuntimeDefault` seccomp profile.
- **Gateway API Ingress**: Renders an `HTTPRoute` from the `httpRoute` values attached to the shared Envoy Gateway.
- **Network Isolation**: A `CiliumNetworkPolicy` admits only the namespace, the node, and the gateway.
- **No API Access**: The pod does not mount a service account token.
- **Reloader Integration**: The deployment carries `configmap.reloader.stakater.com/reload` for its dashboard `ConfigMap`, so Stakater Reloader restarts it when the dashboard configuration changes.

## Dependencies

- **Chart Type**: Native platform chart without upstream dependencies.
- **Runtime Controller**: [Reloader](reloader.md) for automatic restarts.

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/homer/values.schema.json) and [values.yaml](../../kubernetes/catalog/homer/values.yaml).

Key configuration parameters:

- `httpRoute`: Set `httpRoute.hostname` in instance values.
- `dashboard.services`: Set in instance values to define service groups, icons, and URLs.
- `image`: Repository, tag, and `@sha256:` digest.
- `networkPolicy`: Namespace-wide `CiliumNetworkPolicy` (enabled by default, requires Cilium). `port` is the application port that the gateway and the namespaces in `allow` may reach.

## Setup

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `platform`. Include the instance's namespace in the `reloader` instance's `namespaces` list.
