# SonarQube Catalog Application

- [SonarQube Catalog Application](#sonarqube-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `sonarqube` catalog chart deploys the SonarQube Community Build, a self-hosted code quality and security analysis server. Build pipelines, for example [Gitea Runner](gitea-runner.md) jobs, send their analysis results to it.

## Architecture

The chart vendors the upstream SonarQube Helm chart with customized platform templates:

- **Dedicated PostgreSQL Database**: Templates render a CloudNativePG `Cluster` with the image pinned by digest and `Prune=confirm` protection.
- **Dedicated Database Role**: Templates render a non-superuser `DatabaseRole` and the `<INSTANCE>-db` secret from the `db-username` and `db-password` properties.
- **External Secrets Integration**: The `externalSecrets` values create `sonarqube-config` from the `monitoring-passcode` property, `sonarqube-admin` from `admin-password` and `admin-current-password`, and `sonarqube-db` from `db-username` and `db-password` of `secret/sonarqube`. SonarQube connects through `jdbcOverwrite` with the credentials of `sonarqube-db`.
- **Administrator Password**: The upstream hook job changes the password of the `admin` user from `sonarqube-admin` after each sync.
- **Persistent Data Volume**: A volume for the search index, extensions, and logs.
- **Gateway API Ingress**: An `HTTPRoute` from the `httpRoute` values attached to the shared Envoy Gateway; the upstream route cannot select a listener.
- **Immutable Image**: The pulled image is pinned by tag and `@sha256:` digest through `global.azure.images`, because the chart derives a label from `image.tag`, which cannot carry a digest.
- **Pod Security Hardening**: Runs as non-root user `1000` with no privilege escalation, all capabilities dropped, and the `RuntimeDefault` seccomp profile. The service account is created without token mounting. The privileged `initSysctl` and root `initFs` init containers are disabled.
- **Automatic Restarts**: The pod carries `reloader.stakater.com/auto` so Stakater Reloader restarts it when the credential secrets change.

## Dependencies

- **Upstream Chart**: `sonarqube`, pinned in [Chart.yaml](../../kubernetes/catalog/sonarqube/Chart.yaml).
- **Database Engine**: The [CloudNativePG](cloudnative-pg.md) operator.
- **Secrets Provider**: [OpenBao](openbao.md) through [External Secrets](external-secrets.md).
- **Restarts**: [Reloader](reloader.md); add the namespace to its instance values.

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/sonarqube/values.schema.json) and [values.yaml](../../kubernetes/catalog/sonarqube/values.yaml).

Key configuration parameters:

- `httpRoute`: Set `httpRoute.hostname` in instance values.
- `sonarqube.resources`: SonarQube runs a web server, a compute engine, and a search engine in one pod; the defaults request 4 GB of memory.
- `sonarqube.persistence.size`: Size of the data volume.
- `database`: Image, storage size, and resources of the CloudNativePG cluster; instances may set `database.storage.storageClass`; otherwise the cluster default applies.
- `networkPolicy`: Namespace-wide `CiliumNetworkPolicy` (enabled by default, requires Cilium). `port` is the application port that the gateway and the namespaces in `allow` may reach. Instances add the namespaces of the build jobs that submit analyses to `allow`.

## Setup

The search engine needs `vm.max_map_count` of at least `524288` and `fs.file-max` of at least `131072` on the node. The chart does not set them, because that would require a privileged init container. Set them on every node that can run the pod:

```sh
sudo sysctl -w vm.max_map_count=524288 fs.file-max=131072
```

> [!NOTE]
> On development nodes that cannot be tuned, set `sonarqube.elasticsearch.bootstrapChecks` to `false` in the instance values to skip the checks.

Then seed `secret/sonarqube` as described in [Seed Application Secrets](openbao.md#seed-application-secrets) with this content:

```json
{
  "monitoring-passcode": "<MONITORING_PASSCODE>",
  "admin-password": "<ADMIN_PASSWORD>",
  "admin-current-password": "admin",
  "db-username": "sonarqube",
  "db-password": "<DATABASE_PASSWORD>"
}
```

`monitoring-passcode` authenticates the health probes. `admin-current-password` is the password the hook changes; it is `admin` on the first sync. After the first sync, set it to the value of `admin-password`, so later syncs do not retry with the old password. `db-username` is the PostgreSQL login and must be `sonarqube`.

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `workload`. The release name must be `sonarqube`, because the values refer to resources named after it. Wait for the generated resources before using SonarQube:

```sh
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  externalsecret/<INSTANCE>-config externalsecret/<INSTANCE>-admin externalsecret/<INSTANCE>-db --timeout=5m
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  cluster.postgresql.cnpg.io/<INSTANCE>-db --timeout=10m
kubectl wait -n <NAMESPACE> --for=condition=Ready \
  databaserole.postgresql.cnpg.io/<INSTANCE>-app --timeout=5m
```

The first start initializes the database and the search index, which takes several minutes. Then sign in as `admin` with the password from `admin-password`.

> [!NOTE]
> The database and the data volume are not backups; arrange off-cluster backups before relying on the analysis history.
