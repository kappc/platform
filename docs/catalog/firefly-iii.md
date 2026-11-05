# Firefly III Catalog Application

- [Firefly III Catalog Application](#firefly-iii-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `firefly-iii` catalog chart deploys Firefly III, a self-hosted personal finance manager that tracks income, expenses, budgets, and accounts, with rules, recurring transactions, and reports.

## Architecture

The chart vendors the upstream Firefly III Helm chart with customized platform templates:

- **Dedicated PostgreSQL Database**: Templates render a CloudNativePG `Cluster` with the image pinned by digest and `Prune=confirm` protection.
- **Dedicated Database Role**: Templates render a non-superuser `DatabaseRole` and the `<INSTANCE>-db` secret from the `db-username` and `db-password` properties.
- **External Secrets Integration**: The `externalSecrets` values create `firefly-iii-config` from the `app-key`, `db-password`, and `cron-token` properties and `firefly-iii-db` from `db-username` and `db-password` of `secret/firefly-iii`. The pod loads `firefly-iii-config` as environment (`APP_KEY`, `DB_PASSWORD`, `STATIC_CRON_TOKEN`), where it takes precedence over the key the upstream chart generates.
- **Recurring Tasks**: A `CronJob` calls the cron endpoint of Firefly III every day at 03:00 with `STATIC_CRON_TOKEN`, using a pinned `curl` image under non-root user `100`.
- **Persistent Upload Volume**: A volume for uploaded attachments.
- **Gateway API Ingress**: An `HTTPRoute` from the `httpRoute` values attached to the shared Envoy Gateway; the upstream route is not used.
- **Pod Security Hardening**: Runs as non-root user and group `33` with no privilege escalation, all capabilities dropped, and the `RuntimeDefault` seccomp profile.
- **Automatic Restarts**: The pod template carries `reloader.stakater.com/auto` so Stakater Reloader restarts it when the credential secrets change.

## Dependencies

- **Upstream Chart**: `firefly-iii`, pinned in [Chart.yaml](../../kubernetes/catalog/firefly-iii/Chart.yaml).
- **Database Engine**: The [CloudNativePG](cloudnative-pg.md) operator.
- **Secrets Provider**: [OpenBao](openbao.md) through [External Secrets](external-secrets.md).
- **Restarts**: [Reloader](reloader.md); add the namespace to its instance values.

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/firefly-iii/values.schema.json) and [values.yaml](../../kubernetes/catalog/firefly-iii/values.yaml).

Key configuration parameters:

- `httpRoute`: Set `httpRoute.hostname` in instance values. Instances set the public URL in `firefly-iii.config.env.APP_URL` to match.
- `firefly-iii.config.env`: Settings of Firefly III as environment variables. Instances set `APP_URL` to the public URL and `TZ`; `DB_HOST`, `DB_DATABASE`, and `DB_USERNAME` point at the database of an instance named `firefly-iii`.
- `firefly-iii.persistence`: Size of the upload volume.
- `database`: Image, storage size, and resources of the CloudNativePG cluster; instances may set `database.storage.storageClass`; otherwise the cluster default applies.
- `networkPolicy`: Namespace-wide `CiliumNetworkPolicy` (enabled by default, requires Cilium). `port` is the application port that the gateway and the namespaces in `allow` may reach.

## Setup

Before syncing the instance, seed `secret/firefly-iii` as described in [Seed Application Secrets](openbao.md#seed-application-secrets) with this content:

```json
{
  "app-key": "<APP_KEY>",
  "cron-token": "<CRON_TOKEN>",
  "db-username": "firefly-iii",
  "db-password": "<DATABASE_PASSWORD>"
}
```

`app-key` and `cron-token` must be random strings of exactly 32 characters; keep `app-key` stable, because it encrypts stored data. `db-username` is the PostgreSQL login and must be `firefly-iii`.

The upstream chart generates a second `APP_KEY` secret with a random value on every render, which Argo CD reports as a permanent difference. Ignore it in the instance descriptor:

```yaml
argocd:
  ignoreDifferences:
    - group: ""
      kind: Secret
      name: firefly-iii-app-key
      jsonPointers:
        - /data
```

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `workload`. The release name must be `firefly-iii`, because the values refer to resources named after it. Wait for the generated resources before using Firefly III:

```sh
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  externalsecret/<INSTANCE>-config externalsecret/<INSTANCE>-db --timeout=5m
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  cluster.postgresql.cnpg.io/<INSTANCE>-db --timeout=10m
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  databaserole.postgresql.cnpg.io/<INSTANCE>-app --timeout=5m
```

Open the public URL and register the first user, who becomes the owner.

> [!NOTE]
> The database and the upload volume are not backups; arrange off-cluster backups before storing financial data.
