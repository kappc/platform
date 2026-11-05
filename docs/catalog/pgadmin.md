# pgAdmin Catalog Application

- [pgAdmin Catalog Application](#pgadmin-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `pgadmin` catalog chart deploys pgAdmin 4, a web-based administration and development tool for PostgreSQL. It connects to the CloudNativePG clusters of other applications to browse data, run queries, and manage roles.

## Architecture

The chart vendors the upstream pgAdmin 4 Helm chart with customized platform templates:

- **External Secrets Integration**: The `externalSecrets` values create `pgadmin-config` from the `admin-password` property of `secret/pgadmin`; the pod reads the initial administrator password from it.
- **Persistent Data Volume**: A volume for the pgAdmin configuration database, saved servers, and user files.
- **Gateway API Ingress**: An `HTTPRoute` from the `httpRoute` values attached to the shared Envoy Gateway; the upstream route is not used.
- **Pod Security Hardening**: Runs as non-root user and group `5050` with a read-only root filesystem, no privilege escalation, all capabilities dropped, and the `RuntimeDefault` seccomp profile, listening on port `8080`. The service account is created without token mounting.
- **Network Isolation**: The upstream `NetworkPolicy` is disabled in favor of a `CiliumNetworkPolicy`, which admits only the namespace, the node, and the gateway.
- **Automatic Restarts**: The pod template carries `reloader.stakater.com/auto` so Stakater Reloader restarts it when the password secret changes.

## Dependencies

- **Upstream Chart**: `pgadmin4`, pinned in [Chart.yaml](../../kubernetes/catalog/pgadmin/Chart.yaml).
- **Secrets Provider**: [OpenBao](openbao.md) through [External Secrets](external-secrets.md).
- **Restarts**: [Reloader](reloader.md); add the namespace to its instance values.

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/pgadmin/values.schema.json) and [values.yaml](../../kubernetes/catalog/pgadmin/values.yaml).

Key configuration parameters:

- `httpRoute`: Set `httpRoute.hostname` in instance values.
- `pgadmin4.env.email`: Set in instance values to the administrator login. pgAdmin rejects special-use domains such as `.test` and `.local`.
- `pgadmin4.serverDefinitions`: Optional servers that pgAdmin imports when it creates its configuration database for the first time, for example the `<INSTANCE>-db-rw` services of CloudNativePG clusters.
- `pgadmin4.persistentVolume`: Size and storage class of the data volume.
- `networkPolicy`: Namespace-wide `CiliumNetworkPolicy` (enabled by default, requires Cilium). `port` is the application port that the gateway and the namespaces in `allow` may reach.

## Setup

Before syncing the instance, seed `secret/pgadmin` as described in [Seed Application Secrets](openbao.md#seed-application-secrets) with this content:

```json
{
  "admin-password": "<ADMIN_PASSWORD>"
}
```

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `workload`. The release name must be `pgadmin`, because the values refer to resources named after it. Wait for the generated secret before using pgAdmin:

```sh
kubectl wait -n <NAMESPACE> --for=condition=Ready externalsecret/<INSTANCE>-config --timeout=5m
```

pgAdmin only reaches databases that admit its namespace. Add an `allowRules` entry to the [Cilium Policies](cilium-policies.md) instance with `to.namespace` set to the namespace of the database, `fromNamespaces` set to the pgAdmin namespace, and `ports` set to `5432`. Then register a server for the read-write service of the database with the credentials from its OpenBao entry.

> [!NOTE]
> pgAdmin applies the administrator email and password only when it creates its configuration database on the first start. Change them afterwards in the pgAdmin interface.
