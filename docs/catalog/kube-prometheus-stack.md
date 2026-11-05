# Kube Prometheus Stack Catalog Application

- [Kube Prometheus Stack Catalog Application](#kube-prometheus-stack-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `kube-prometheus-stack` catalog chart deploys a complete end-to-end Kubernetes observability stack powered by the Prometheus Operator. It includes Prometheus for metric collection and alerting, Alertmanager for notification routing, Node Exporter and kube-state-metrics, and Grafana for visualization dashboards.

## Architecture

The chart vendors the upstream Prometheus Community Helm chart with customized platform templates:

- **Grafana Credentials**: The `externalSecrets` values create the `grafana-admin` secret from the `grafana-admin-username` and `grafana-admin-password` properties of `secret/monitoring`.
- **Persistent Storage**: Grafana and Prometheus use persistent volumes.
- **Gateway API Ingress**: An `HTTPRoute` from the `httpRoute` values exposes Grafana through the shared Envoy Gateway.

## Dependencies

- **Upstream Chart**: `kube-prometheus-stack`, pinned in [Chart.yaml](../../kubernetes/catalog/kube-prometheus-stack/Chart.yaml).
- **Secrets Backend**: `openbao` through `external-secrets`.

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/kube-prometheus-stack/values.schema.json) and [values.yaml](../../kubernetes/catalog/kube-prometheus-stack/values.yaml).

Key configuration parameters:

- `kube-prometheus-stack.grafana.admin.existingSecret`: Points to the `grafana-admin` secret managed by External Secrets Operator.
- `kube-prometheus-stack.prometheus.prometheusSpec`: Retention, retention size, and volume claim size for Prometheus.
- `httpRoute`: Exposes Grafana via `httpRoute.hostname` (e.g. `grafana.<DOMAIN>`); set `httpRoute.enabled` to `false` to keep it internal.
- `networkPolicy`: Disabled, because the library policy covers a single application port while this namespace serves several components.

## Setup

Before syncing the instance, seed `secret/monitoring` as described in [Seed Application Secrets](openbao.md#seed-application-secrets) with this content. The credentials are synchronized by External Secrets and are never stored in Helm values:

```json
{
  "grafana-admin-username": "<ADMIN_USERNAME>",
  "grafana-admin-password": "<ADMIN_PASSWORD>"
}
```

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `platform`.
