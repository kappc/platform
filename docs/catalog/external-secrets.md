# External Secrets Catalog Application

- [External Secrets Catalog Application](#external-secrets-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `external-secrets` catalog chart deploys the External Secrets Operator (ESO). ESO connects Kubernetes to external secret management systems (like OpenBao or HashiCorp Vault) and continuously reconciles external credentials into standard Kubernetes `Secret` resources.

## Architecture

The chart vendors the upstream External Secrets Helm chart:

- **Component Footprint**: Deploys the core controller, admission webhook, and certificate controller with constrained CPU and memory bounds.
- **Provider Decoupling**: Applications define `ExternalSecret` manifests that reference the shared `openbao` `ClusterSecretStore`; ESO authenticates to OpenBao with Kubernetes service account tokens (audience `openbao`).
- **Target Ownership**: Target `Secret` resources use `creationPolicy: Owner` and `deletionPolicy: Retain`, so secrets persist during transient failures.

## Dependencies

- **Upstream Chart**: `external-secrets`, pinned in [Chart.yaml](../../kubernetes/catalog/external-secrets/Chart.yaml).

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/external-secrets/values.schema.json) and [values.yaml](../../kubernetes/catalog/external-secrets/values.yaml).

Key configuration parameters:

- `external-secrets.resources`: CPU and memory resource bounds for the operator controller.
- `external-secrets.webhook.resources` and `external-secrets.certController.resources`: Resource bounds for admission and cert-controller components.

## Setup

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `infrastructure`. The `ClusterSecretStore` itself is created by the [OpenBao](openbao.md) chart.
