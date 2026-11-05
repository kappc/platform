# Gitea Catalog Application

- [Gitea Catalog Application](#gitea-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)
    - [Rotate Credentials](#rotate-credentials)

## Overview

The `gitea` catalog chart deploys Gitea, a lightweight self-hosted Git service with pull requests, issue tracking, a package registry, and Gitea Actions for CI/CD. Runners for Actions come from the [Gitea Runner](gitea-runner.md) chart.

## Architecture

The chart vendors the upstream Gitea Helm chart with customized platform templates:

- **Dedicated PostgreSQL Database**: Templates render a CloudNativePG `Cluster` with the image pinned by digest and `Prune=confirm` protection. The bundled PostgreSQL and PostgreSQL HA subcharts are disabled.
- **Dedicated Database Role**: Templates render a non-superuser `DatabaseRole` and the `<INSTANCE>-db` secret from the `db-username` and `db-password` properties.
- **External Secrets Integration**: The `externalSecrets` values create `gitea-admin` from the `admin-username` and `admin-password` properties and `gitea-db` from `db-username` and `db-password` of `secret/gitea`. Gitea reads the database password from `gitea-db` through `GITEA__DATABASE__PASSWD`.
- **In-Process Cache**: The bundled Valkey subcharts are disabled, so cache, session, and queue run inside the single Gitea pod. The chart therefore supports one replica.
- **Persistent Data Volume**: A volume for repositories, attachments, and the queue; the claim carries `helm.sh/resource-policy: keep`.
- **Gateway API Ingress**: An `HTTPRoute` from the `httpRoute` values attached to the shared Envoy Gateway; the upstream route is not used.
- **Pod Security Hardening**: The rootless image runs as non-root user and group `1000` with a read-only root filesystem, no privilege escalation, all capabilities dropped, and the `RuntimeDefault` seccomp profile. The service account is created without token mounting.
- **Automatic Restarts**: The deployment carries `reloader.stakater.com/auto` so Stakater Reloader restarts it when the credential secrets change.
- **Closed Registration**: Self-registration is disabled; administrators create accounts.

## Dependencies

- **Upstream Chart**: `gitea`, pinned in [Chart.yaml](../../kubernetes/catalog/gitea/Chart.yaml).
- **Database Engine**: The [CloudNativePG](cloudnative-pg.md) operator.
- **Secrets Provider**: [OpenBao](openbao.md) through [External Secrets](external-secrets.md).
- **Restarts**: [Reloader](reloader.md); add the namespace to its instance values.

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/gitea/values.schema.json) and [values.yaml](../../kubernetes/catalog/gitea/values.yaml).

Key configuration parameters:

- `httpRoute`: Set `httpRoute.hostname` in instance values. Instances set the public URL in `gitea.gitea.config.server.ROOT_URL` and `gitea.gitea.config.server.DOMAIN` to match.
- `gitea.gitea.admin.email`: Email address of the administrator account.
- `gitea.persistence.size`: Size of the data volume.
- `database`: Image, storage size, and resources of the CloudNativePG cluster; instances may set `database.storage.storageClass`; otherwise the cluster default applies.
- `networkPolicy`: Namespace-wide `CiliumNetworkPolicy` (enabled by default, requires Cilium). `port` is the application port that the gateway and the namespaces in `allow` may reach. The catalog allows the [Gitea Runner](gitea-runner.md) namespace `gitea-runner`.

## Setup

Before syncing the instance, seed `secret/gitea` as described in [Seed Application Secrets](openbao.md#seed-application-secrets) with this content:

```json
{
  "admin-username": "<ADMIN_USERNAME>",
  "admin-password": "<ADMIN_PASSWORD>",
  "db-username": "gitea",
  "db-password": "<DATABASE_PASSWORD>"
}
```

`admin-username` is the Gitea administrator and must not be `admin`, which Gitea reserves. `db-username` is the PostgreSQL login and must be `gitea`.

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `workload`. The release name must be `gitea`, because the values refer to resources named after it. Wait for the generated resources before using Gitea:

```sh
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  externalsecret/<INSTANCE>-admin externalsecret/<INSTANCE>-db --timeout=5m
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  cluster.postgresql.cnpg.io/<INSTANCE>-db --timeout=10m
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  databaserole.postgresql.cnpg.io/<INSTANCE>-app --timeout=5m
```

> [!NOTE]
> Git over SSH runs on port `2222` of the `<INSTANCE>-ssh` service, which the gateway does not expose; clone over HTTP or HTTPS. The repository volume and the database are not backups; arrange off-cluster backups before storing important code.

### Rotate Credentials

Update the password in OpenBao and let External Secrets sync it; Reloader then restarts Gitea. For the database password, also wait until CloudNativePG has applied the new role password. The chart resets the administrator password to the value in OpenBao on every start.
