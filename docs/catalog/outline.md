# Outline Catalog Application

- [Outline Catalog Application](#outline-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `outline` catalog chart deploys Outline, a modern, fast, collaborative knowledge base and wiki for teams. It features real-time markdown collaboration, structured collections, document history, and enterprise Single Sign-On via Authentik OIDC.

## Architecture

The chart vendors the upstream Outline Community Helm chart with customized platform templates:

- **Dedicated PostgreSQL Database**: Templates render a CloudNativePG `Cluster` with the image pinned by digest and `Prune=confirm` protection.
- **Dedicated Database Role**: Templates render a non-superuser `DatabaseRole` and the `<INSTANCE>-db` secret from the `db-username` and `db-password` properties.
- **External Secrets Integration**: The `externalSecrets` values create `outline-config` (`secret-key`, `utils-secret`, `oidc-client-secret`), `outline-db`, and `outline-redis` from `secret/outline`.
- **Redis**: The upstream Bitnami Redis subchart in standalone mode with password authentication from the `outline-redis` secret and no persistence. The image tag is overridden with a pinned tag and digest from the frozen `bitnamilegacy/redis` repository, because Bitnami only publishes `latest` for the default repository. The legacy image receives no security updates.
- **File Storage**: A persistent volume for uploaded files.
- **OIDC Sign-In**: Users sign in through an external OIDC provider.
- **Gateway API Ingress**: An `HTTPRoute` from the `httpRoute` values attached to the shared Envoy Gateway.

## Dependencies

- **Upstream Chart**: `outline`, pinned in [Chart.yaml](../../kubernetes/catalog/outline/Chart.yaml).
- **Database Engine**: The [CloudNativePG](cloudnative-pg.md) operator.
- **Identity Provider**: An OIDC provider such as [Authentik](authentik.md).
- **Secrets Provider**: [OpenBao](openbao.md) through [External Secrets](external-secrets.md).

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/outline/values.schema.json) and [values.yaml](../../kubernetes/catalog/outline/values.yaml).

Key configuration parameters:

- `httpRoute`: Set `httpRoute.hostname` in instance values.
- `outline.url`: Public base URL of Outline; set in instance values.
- `outline.auth.oidc`: OIDC endpoints (`authUri`, `tokenUri`, `userInfoUri`) and `scopes` of the identity provider. The in-cluster Authentik endpoints and scopes are defaults; instances set `authUri`.
- `database`: Image, storage size, and resources of the CloudNativePG cluster; instances may set `database.storage.storageClass`; otherwise the cluster default applies.
- `outline.redis.image`: Tag and digest of the Redis image; the Bitnami subchart does not work with other image layouts such as the official Redis image.
- `networkPolicy`: Namespace-wide `CiliumNetworkPolicy` (enabled by default, requires Cilium). `port` is the application port that the gateway and the namespaces in `allow` may reach.

## Setup

Create a confidential OAuth2/OpenID provider and an application with client ID `outline` in the identity provider. Use the redirect URI `<OUTLINE_URL>/auth/oidc.callback` and the scopes `openid`, `profile`, and `email`, and note the client secret. The authorization endpoint must use the browser-accessible host of the identity provider; the token and user info endpoints can use its in-cluster service.

Before syncing the instance, seed `secret/outline` as described in [Seed Application Secrets](openbao.md#seed-application-secrets) with this content:

```json
{
  "secret-key": "<SECRET_KEY>",
  "utils-secret": "<UTILS_SECRET>",
  "oidc-client-secret": "<OIDC_CLIENT_SECRET>",
  "db-username": "outline",
  "db-password": "<DATABASE_PASSWORD>",
  "redis-password": "<REDIS_PASSWORD>"
}
```

Use two different long random values for `secret-key` and `utils-secret` and keep both stable.

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `workload`. The release name must be `outline`, because the values refer to resources named after it. Wait for the generated resources before using Outline:

```sh
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  externalsecret/outline-config externalsecret/outline-db externalsecret/outline-redis --timeout=5m
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  cluster.postgresql.cnpg.io/<INSTANCE>-db --timeout=10m
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  databaserole.postgresql.cnpg.io/<INSTANCE>-app --timeout=5m
```

> [!NOTE]
> The chart disables the HTTPS redirect (`outline.web.forceHttps: false`) for gateways that serve HTTP only. The attachment volume and the database are not backups; arrange off-cluster backups before storing important content.
