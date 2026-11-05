# Mail Archiver Catalog Application

- [Mail Archiver Catalog Application](#mail-archiver-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `mail-archiver` catalog chart is a native platform chart that deploys [Mail Archiver](https://github.com/s1t5/mail-archiver), a web application that archives, searches, and exports emails from IMAP, Microsoft 365, and imported mailboxes.

## Architecture

- **Single Instance**: One pod (`deployment.yaml`, strategy `Recreate`), because the background sync and import services must not run twice. The image is pinned by tag and `@sha256:` digest.
- **Dedicated PostgreSQL Database**: Templates render a CloudNativePG `Cluster` with the image pinned by digest and `Prune=confirm` protection. The application creates its schema and the `citext` extension on startup.
- **Dedicated Database Role**: Templates render a non-superuser `DatabaseRole` and the `<INSTANCE>-db` secret from the `db-username` and `db-password` properties.
- **External Secrets Integration**: The `externalSecrets` values create `mail-archiver-config` and `mail-archiver-db` from `secret/mail-archiver`. The config secret holds the database connection string, which the template composes with the `db-password` property, the administrator credentials, and the key that encrypts mailbox credentials at rest.
- **Persistent Key Volume**: The `<INSTANCE>-keys` volume stores the ASP.NET data protection keys, so sessions and anti-forgery tokens survive restarts.
- **Pod Security Hardening**: Runs as non-root user and group `1654` with a read-only root filesystem, no privilege escalation, all capabilities dropped, and the `RuntimeDefault` seccomp profile. The writable paths `/tmp`, `/app/uploads`, and `/app/exports` are `emptyDir` volumes. The pod does not mount a service account token.
- **Host Validation**: `AllowedHosts` is set to the route hostname, and the probes send that hostname in the `Host` header.
- **Gateway API Ingress**: An `HTTPRoute` from the `httpRoute` values attached to the shared Envoy Gateway. The application serves plain HTTP, so TLS terminates at the gateway.
- **Network Isolation**: A `CiliumNetworkPolicy` admits only the namespace, the node, and the gateway.
- **Automatic Restarts**: The deployment carries `reloader.stakater.com/auto` so Stakater Reloader restarts it when the config secret changes.

## Dependencies

- **Chart Type**: Native platform chart without upstream dependencies.
- **Database Engine**: The [CloudNativePG](cloudnative-pg.md) operator.
- **Secrets Provider**: [OpenBao](openbao.md) through [External Secrets](external-secrets.md).
- **Restarts**: [Reloader](reloader.md); add the namespace to its instance values.

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/mail-archiver/values.schema.json) and [values.yaml](../../kubernetes/catalog/mail-archiver/values.yaml).

Key configuration parameters:

- `httpRoute`: Set `httpRoute.hostname` in instance values; it also restricts the accepted `Host` headers.
- `env`: Application settings as environment variables of the form `Section__Key`, for example `TimeZone__DisplayTimeZoneId` or `MailSync__IntervalMinutes`. Never put secrets here; see the [Setup Guide](https://s1t5.github.io/mail-archiver/Setup/) for all settings.
- `image`: Repository, tag, and `@sha256:` digest.
- `persistence`: Storage class and size of the key volume.
- `database`: Image, storage size, and resources of the CloudNativePG cluster; instances may set `database.storage.storageClass`; otherwise the cluster default applies.
- `networkPolicy`: Namespace-wide `CiliumNetworkPolicy` (enabled by default, requires Cilium). `port` is the application port that the gateway and the namespaces in `allow` may reach.

## Setup

Before syncing the instance, generate the encryption key with `openssl rand -base64 32`, then seed `secret/mail-archiver` as described in [Seed Application Secrets](openbao.md#seed-application-secrets) with this content:

```json
{
  "admin-username": "<ADMIN_USERNAME>",
  "admin-password": "<ADMIN_PASSWORD>",
  "encryption-key": "<ENCRYPTION_KEY>",
  "db-username": "mail-archiver",
  "db-password": "<DATABASE_PASSWORD>"
}
```

`db-username` is the PostgreSQL login and must be `mail-archiver`. Use only letters and digits in `db-password`, because the connection string does not quote it.

> [!IMPORTANT]
> Back up `encryption-key` separately from the database. Without it, the encrypted mailbox credentials cannot be read and must be entered again.

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `workload`. The release name must be `mail-archiver`, because the values refer to resources named after it. Wait for the generated resources before using Mail Archiver:

```sh
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  externalsecret/<INSTANCE>-config externalsecret/<INSTANCE>-db --timeout=5m
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  cluster.postgresql.cnpg.io/<INSTANCE>-db --timeout=10m
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  databaserole.postgresql.cnpg.io/<INSTANCE>-app --timeout=5m
```

Sign in with the administrator credentials, then add the mail accounts to archive under `Email Accounts`.

> [!NOTE]
> The scratch volumes for uploads and exports live on the node and count against its ephemeral storage. The database holds the archive and is not a backup; arrange off-cluster backups before relying on the archive.
