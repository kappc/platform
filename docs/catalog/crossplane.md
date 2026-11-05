# Crossplane Catalog Application

- [Crossplane Catalog Application](#crossplane-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `crossplane` catalog chart installs Crossplane core, a framework that transforms a Kubernetes cluster into a universal control plane. Crossplane enables infrastructure-as-code provisioning and composite resource orchestration across public clouds and on-premises environments.

## Architecture

The chart vendors the upstream Crossplane chart:

- **Lean Core**: Installs only the Crossplane core with one replica.
- **On-Demand Packages**: Provider, configuration, and function package lists are empty; add packages only when a specific infrastructure API is needed.
- **Pod Hardening**: Both pods run as non-root with the `RuntimeDefault` seccomp profile and all capabilities dropped, on top of the upstream read-only root filesystem.

## Dependencies

- **Upstream Chart**: `crossplane`, pinned in [Chart.yaml](../../kubernetes/catalog/crossplane/Chart.yaml).

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/crossplane/values.schema.json) and [values.yaml](../../kubernetes/catalog/crossplane/values.yaml).

Key configuration parameters:

- `crossplane.replicas`: Number of controller replicas.
- `crossplane.provider.packages`, `crossplane.configuration.packages`, `crossplane.function.packages`: Package lists to extend the control plane.

## Setup

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `platform`.
