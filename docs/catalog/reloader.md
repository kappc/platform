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

- **Scoped Watching**: `watchGlobally: false` limits Reloader to the configured namespaces.
- **Opt-In Reloads**: Workloads opt in with annotations such as `configmap.reloader.stakater.com/reload` or `reloader.stakater.com/auto: "true"`.
- **Secret Rotation**: Restarts workloads when External Secrets updates a synced `Secret`.
- **Container Hardening**: No privilege escalation, a read-only root filesystem, and all capabilities dropped.

## Dependencies

- **Upstream Chart**: `reloader`, pinned in [Chart.yaml](../../kubernetes/catalog/reloader/Chart.yaml).

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/reloader/values.schema.json) and [values.yaml](../../kubernetes/catalog/reloader/values.yaml).

Key configuration parameters:

- `reloader.reloader.watchGlobally`: Keep `false` to restrict monitoring to explicit namespaces.
- `reloader.reloader.namespaces`: Set in instance values to the namespaces whose workloads should be restarted.

## Setup

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `platform`. Add the namespace of every workload that opts in to the `namespaces` list.
