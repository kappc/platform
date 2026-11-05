# Kyverno Catalog Application

- [Kyverno Catalog Application](#kyverno-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `kyverno` catalog chart deploys the Kyverno policy engine for Kubernetes. It runs admission webhooks to validate, mutate, and generate Kubernetes resources, as well as verifying supply chain image signatures and reporting compliance violations.

## Architecture

The chart vendors the upstream Kyverno controller chart:

- **CRD Management**: Installs the Kyverno CustomResourceDefinitions, including `ClusterPolicy` and `ValidatingPolicy`.
- **Conversion Drift**: Kyverno mutates its policy CRDs at runtime (conversion webhook, empty labels and annotations); instances set `argocd.ignoreDifferences` to avoid sync loops.

## Dependencies

- **Upstream Chart**: `kyverno`, pinned in [Chart.yaml](../../kubernetes/catalog/kyverno/Chart.yaml).

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/kyverno/values.schema.json) and [values.yaml](../../kubernetes/catalog/kyverno/values.yaml).

Key configuration parameters:

- `kyverno.crds.install`: Installs the Kyverno CustomResourceDefinitions.
- `argocd.ignoreDifferences`: Set in `instance.yaml` for the CRD mutations described above.

## Setup

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `infrastructure`.
