# Vaultwarden Catalog Application

- [Vaultwarden Catalog Application](#vaultwarden-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `vaultwarden` catalog chart deploys Vaultwarden, a lightweight, Bitwarden-compatible server for managing passwords, passkeys, and secrets with the official Bitwarden clients and web vault.

## Architecture

The chart vendors the upstream Vaultwarden Helm chart with customized platform templates:

- **Dedicated PostgreSQL Database**: Templates render a CloudNativePG `Cluster` with the image pinned by digest and `Prune=confirm` protection.
- **Dedicated Database Role**: Templates render a non-superuser `DatabaseRole` and the `<INSTANCE>-db` secret from the `db-username` and `db-password` properties.
- **External Secrets Integration**: The `externalSecrets` values create `vaultwarden-config` from the `admin-token` property, which feeds `ADMIN_TOKEN`, and `vaultwarden-db` from `db-username` and `db-password` of `secret/vaultwarden`. Vaultwarden connects with the credentials of `vaultwarden-db`.
- **Persistent Data Volume**: A volume for attachments, icons, and the signing keys; the claim carries `helm.sh/resource-policy: keep`.
- **Gateway API Ingress**: An `HTTPRoute` from the `httpRoute` values attached to the **HTTPS** listener of the shared Envoy Gateway; the upstream route is not used.
- **Pod Security Hardening**: Runs as non-root user and group `1001` with a read-only root filesystem, no privilege escalation, all capabilities dropped, and the `RuntimeDefault` seccomp profile.
- **Automatic Restarts**: The deployment carries `reloader.stakater.com/auto` so Stakater Reloader restarts it when the credential secrets change.
- **Closed Registration**: Self-registration is disabled; users join by invitation from the admin page or an organization.

> [!IMPORTANT]
> The web vault and the browser extensions need a secure context. The route therefore attaches to the HTTPS listener (`gateway.tls.enabled` in the [Envoy Gateway](envoy-gateway.md) instance), and clients must trust its certificate.

## Dependencies

- **Upstream Chart**: `vaultwarden`, pinned in [Chart.yaml](../../kubernetes/catalog/vaultwarden/Chart.yaml).
- **Database Engine**: The [CloudNativePG](cloudnative-pg.md) operator.
- **Secrets Provider**: [OpenBao](openbao.md) through [External Secrets](external-secrets.md).
- **TLS**: The HTTPS listener of [Envoy Gateway](envoy-gateway.md) with a certificate from [cert-manager](cert-manager.md).
- **Restarts**: [Reloader](reloader.md); add the namespace to its instance values.

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/vaultwarden/values.schema.json) and [values.yaml](../../kubernetes/catalog/vaultwarden/values.yaml).

Key configuration parameters:

- `vaultwarden.domain`: Set in instance values to the public URL, including the `https` scheme.
- `httpRoute`: Set `httpRoute.hostname` in instance values; the `https` listener is the default because Vaultwarden needs a secure context.
- `vaultwarden.signupsAllowed`: Allows anyone with access to register; disabled by default.
- `vaultwarden.smtp`: Mail server for invitations and verification emails.
- `vaultwarden.storage.data`: Size of the data volume.
- `database`: Image, storage size, and resources of the CloudNativePG cluster; instances may set `database.storage.storageClass`; otherwise the cluster default applies.
- `networkPolicy`: Namespace-wide `CiliumNetworkPolicy` (enabled by default, requires Cilium). `port` is the application port that the gateway and the namespaces in `allow` may reach.

## Setup

Before syncing the instance, generate an Argon2 hash of the admin token, then seed `secret/vaultwarden` as described in [Seed Application Secrets](openbao.md#seed-application-secrets) with this content:

```sh
docker run --rm -it vaultwarden/server:<VERSION>-alpine /vaultwarden hash
```

```json
{
  "admin-token": "<ARGON2_HASH>",
  "db-username": "vaultwarden",
  "db-password": "<DATABASE_PASSWORD>"
}
```

`admin-token` protects the `/admin` page. `db-username` is the PostgreSQL login and must be `vaultwarden`.

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `workload`. The release name must be `vaultwarden`, because the values refer to resources named after it. Wait for the generated resources before using Vaultwarden:

```sh
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  externalsecret/<INSTANCE>-config externalsecret/<INSTANCE>-db --timeout=5m
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  cluster.postgresql.cnpg.io/<INSTANCE>-db --timeout=10m
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  databaserole.postgresql.cnpg.io/<INSTANCE>-app --timeout=5m
```

> [!NOTE]
> The upstream chart cannot switch off the mounting of the service account token. The database and the data volume are not backups, and the vault is lost without them; arrange off-cluster backups before storing credentials.
