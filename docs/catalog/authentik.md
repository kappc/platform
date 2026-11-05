# Authentik Catalog Application

- [Authentik Catalog Application](#authentik-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `authentik` catalog chart deploys Authentik, an open-source Identity Provider (IdP) focused on flexibility and enterprise integration. It provides Single Sign-On (SSO), Multi-Factor Authentication (MFA), OpenID Connect (OIDC), SAML, and user directory management across platform applications.

## Architecture

The chart bundles the upstream Authentik Helm chart with dedicated stateful and security resources:

- **Dedicated PostgreSQL Database**: Templates render a CloudNativePG `Cluster` with the image pinned by digest and `Prune=confirm` protection.
- **Dedicated Database Role**: Templates render a non-superuser `DatabaseRole` and the `<INSTANCE>-db` secret from the `db-username` and `db-password` properties.
- **External Secrets Integration**: The `externalSecrets` values and templates create two `ExternalSecret` resources:
  - `authentik-config`: Synchronizes `AUTHENTIK_SECRET_KEY`, `AUTHENTIK_POSTGRESQL__PASSWORD`, and `AUTHENTIK_BOOTSTRAP_PASSWORD`.
  - `authentik-db`: Synchronizes the basic auth database credentials.
- **Gateway API Ingress**: An `HTTPRoute` from the `httpRoute` values attached to the shared Envoy Gateway; the upstream route is not used.
- **Pod Hardening**: Server and worker run as user `1000` with the `RuntimeDefault` seccomp profile, no privilege escalation, and all capabilities dropped.

## Dependencies

- **Upstream Chart**: `authentik`, pinned in [Chart.yaml](../../kubernetes/catalog/authentik/Chart.yaml).
- **Database Engine**: The `cloudnative-pg` operator.
- **Secrets Backend**: `openbao` through `external-secrets`.

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/authentik/values.schema.json) and [values.yaml](../../kubernetes/catalog/authentik/values.yaml).

Key configuration parameters:

- `database`: Storage size and resource limits of the dedicated CloudNativePG cluster. Instances may set `database.storage.storageClass`; otherwise the cluster default applies.
- `httpRoute`: Set `httpRoute.hostname` in instance values; `service` selects the `authentik-server` service.
- `authentik.authentik.existingSecret`: Points to the `authentik-config` secret created by External Secrets Operator.
- `networkPolicy`: Namespace-wide `CiliumNetworkPolicy` (enabled by default, requires Cilium). `port` is the application port that the gateway and the namespaces in `allow` may reach. The catalog allows the `outline` namespace; instances add further OIDC clients.

## Setup

Before syncing the instance, seed `secret/authentik` as described in [Seed Application Secrets](openbao.md#seed-application-secrets) with this content:

```json
{
  "secret-key": "<SECRET_KEY>",
  "bootstrap-password": "<ADMIN_PASSWORD>",
  "db-username": "authentik",
  "db-password": "<DATABASE_PASSWORD>"
}
```

The secret key must be long, random, and stable across upgrades. The bootstrap password initializes the `akadmin` account; rotate it in Authentik after the first sign-in. Keep the PostgreSQL username `authentik`.

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `platform`. The release name must be `authentik`, because the values refer to resources named after it. After the operators are healthy, verify the generated resources:

```sh
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  externalsecret/<INSTANCE>-config externalsecret/<INSTANCE>-db --timeout=5m
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  cluster.postgresql.cnpg.io/<INSTANCE>-db --timeout=10m
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  databaserole.postgresql.cnpg.io/<INSTANCE>-app --timeout=5m
```

Then sign in as `akadmin` with the bootstrap password.
