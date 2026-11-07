# Reloader Catalog Application

- [Reloader Catalog Application](#reloader-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `reloader` catalog chart deploys Stakater Reloader, an automated Kubernetes controller that watches changes in `ConfigMap` and `Secret` resources and triggers rolling upgrades on associated `Deployments`, `StatefulSets`, and `DaemonSets`.

## Architecture

The chart vendors the upstream Stakater Reloader Helm chart:

- **Global Watching**: `watchGlobally: true` lets Reloader watch ConfigMaps and Secrets across namespaces, including namespaces created after Reloader is installed.
- **Opt-In Reloads**: Workloads opt in with annotations such as `configmap.reloader.stakater.com/reload` or `reloader.stakater.com/auto: "true"`.
- **Secret Rotation**: Restarts workloads when External Secrets updates a synced `Secret`.
- **Container Hardening**: No privilege escalation, a read-only root filesystem, and all capabilities dropped.
- **Cluster-Wide Permissions**: Global watching requires a `ClusterRole` and `ClusterRoleBinding` with access across namespaces.

## Dependencies

- **Upstream Chart**: `reloader`, pinned in [Chart.yaml](../../kubernetes/catalog/reloader/Chart.yaml).

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/reloader/values.schema.json) and [values.yaml](../../kubernetes/catalog/reloader/values.yaml).

Key configuration parameters:

- `reloader.reloader.watchGlobally`: Enabled so newly created namespaces are watched without pre-creating them or updating Reloader values.
- `reloader.reloader.namespaceSelector`: Optional namespace label selector when global RBAC is acceptable but watching should be limited to selected namespaces.

## Setup

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `platform`. Global watching needs no namespace list or namespace labels; workloads still opt in through Reloader annotations. The upstream chart grants cluster-wide RBAC, so use scoped watching instead on clusters with untrusted tenants.
