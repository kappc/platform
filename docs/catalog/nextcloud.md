# Nextcloud Catalog Application

- [Nextcloud Catalog Application](#nextcloud-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)
    - [Rotate Credentials](#rotate-credentials)

## Overview

The `nextcloud` catalog chart deploys Nextcloud Hub, a self-hosted content collaboration and productivity platform providing file sync and share, documents, calendars, contacts, and communication tools.

## Architecture

The chart bundles the upstream Nextcloud Helm chart with dedicated stateful and security resources:

- **Dedicated PostgreSQL Database**: Templates render a CloudNativePG `Cluster` with the image pinned by digest and `Prune=confirm` protection.
- **Dedicated Database Role**: Templates render a non-superuser `DatabaseRole` and the `<INSTANCE>-db` secret from the `db-username` and `db-password` properties.
- **External Secrets Integration**: The `externalSecrets` values create `nextcloud-admin` from the `admin-username` and `admin-password` properties and `nextcloud-db` from `db-username` and `db-password` of `secret/nextcloud`.
- **Persistent Data Volume**: Persistent storage for user data.
- **Cronjob Execution**: Background jobs run as a scheduled `cronjob` under the non-root user `33` with no privilege escalation, all capabilities dropped, and the `RuntimeDefault` seccomp profile. The web pod keeps the image's privilege model and only adds the seccomp profile.
- **Gateway API Ingress**: An `HTTPRoute` from the `httpRoute` values attached to the shared Envoy Gateway.

## Dependencies

- **Upstream Chart**: `nextcloud`, pinned in [Chart.yaml](../../kubernetes/catalog/nextcloud/Chart.yaml).
- **Database Engine**: The [CloudNativePG](cloudnative-pg.md) operator.
- **Secrets Provider**: [OpenBao](openbao.md) through [External Secrets](external-secrets.md).

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/nextcloud/values.schema.json) and [values.yaml](../../kubernetes/catalog/nextcloud/values.yaml).

Key configuration parameters:

- `httpRoute`: Set `httpRoute.hostname` in instance values.
- `nextcloud.nextcloud.host`: Set in instance values to the public hostname, matching `httpRoute.hostname`.
- `database`: Image, storage size, and resources of the CloudNativePG cluster; instances may set `database.storage.storageClass`; otherwise the cluster default applies.
- `nextcloud.persistence.storageClass`: Storage class for user data; defaults to the cluster default.
- `nextcloud.externalDatabase`: Connects Nextcloud to the CloudNativePG service using the `nextcloud-db` secret.
- `networkPolicy`: Namespace-wide `CiliumNetworkPolicy` (enabled by default, requires Cilium). `port` is the application port that the gateway and the namespaces in `allow` may reach.

## Setup

Before syncing the instance, seed `secret/nextcloud` as described in [Seed Application Secrets](openbao.md#seed-application-secrets) with this content:

```json
{
  "admin-username": "<ADMIN_USERNAME>",
  "admin-password": "<ADMIN_PASSWORD>",
  "db-username": "nextcloud",
  "db-password": "<DATABASE_PASSWORD>"
}
```

`admin-username` is the Nextcloud web administrator. `db-username` is the PostgreSQL login and must be `nextcloud`.

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `workload`. The release name must be `nextcloud`, because the values refer to resources named after it. Wait for the generated resources before using Nextcloud:

```sh
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  externalsecret/<INSTANCE>-admin externalsecret/<INSTANCE>-db --timeout=5m
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  cluster.postgresql.cnpg.io/<INSTANCE>-db --timeout=10m
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  databaserole.postgresql.cnpg.io/<INSTANCE>-app --timeout=5m
```

The chart allows up to 10 minutes for startup so the image can finish its first-install database setup before liveness checks apply. The cronjob runs as UID and GID 33, matching the `www-data` owner of Nextcloud's shared files.

### Rotate Credentials

Update the password in OpenBao and let External Secrets sync it. For the database password, also wait until CloudNativePG has applied the new role password and update the database credentials stored by Nextcloud before resuming the cronjob. Change the administrator password in the Nextcloud administration interface after updating it in OpenBao.
