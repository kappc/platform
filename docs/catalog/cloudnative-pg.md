# CloudNativePG Catalog Application

- [CloudNativePG Catalog Application](#cloudnativepg-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `cloudnative-pg` catalog chart deploys CloudNativePG, the Kubernetes-native operator for managing PostgreSQL databases. It automates cluster provisioning, primary-replica replication, failover, backup, disaster recovery, rolling updates, and user/database lifecycle management.

## Architecture

The chart vendors the upstream CloudNativePG operator chart:

- **CRD Management**: Installs and manages CustomResourceDefinitions including `Cluster`, `Database`, `DatabaseRole`, `Backup`, and `ScheduledBackup`.
- **Operator Footprint**: Runs the operator controller with resource requests and limits.
- **Application Integration**: Applications that need PostgreSQL ship their own `Cluster` and `DatabaseRole` manifests. A cluster per application aligns credentials, storage, backup and restore, upgrades, and resource tuning with that application's lifecycle. Argo CD asks for explicit confirmation before pruning such a cluster.
- **Availability**: The platform runs single-instance clusters, which suits a single-node setup but is not highly available. Volumes are not backups.

## Dependencies

- **Upstream Chart**: `cloudnative-pg`, pinned in [Chart.yaml](../../kubernetes/catalog/cloudnative-pg/Chart.yaml).

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/cloudnative-pg/values.schema.json) and [values.yaml](../../kubernetes/catalog/cloudnative-pg/values.yaml).

Key configuration parameters:

- `cloudnative-pg.resources`: CPU and memory requests and limits for the operator controller managing PostgreSQL clusters across the platform.

## Setup

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `platform`, ahead of the applications that own a database `Cluster`.
