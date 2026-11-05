# Gitea Runner Catalog Application

- [Gitea Runner Catalog Application](#gitea-runner-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `gitea-runner` catalog chart deploys a Gitea Actions runner. The runner registers with a [Gitea](gitea.md) instance and executes the workflow jobs of its repositories in containers.

## Architecture

The chart vendors the upstream Gitea Actions Helm chart (`actions`) with customized platform templates:

- **Runner with Docker Daemon**: The upstream `StatefulSet` runs the runner and a rootless Docker-in-Docker daemon as a native sidecar, which needs Kubernetes 1.29 or later. An init container waits until Gitea answers. All images are pinned by tag and `@sha256:` digest.
- **Registration**: The runner registers with the token from the `<INSTANCE>` secret, which The `externalSecrets` values create from the `registration-token` property of `secret/gitea-runner`. The registration persists in the `data-runner` volume of the pod.
- **Image Cache**: A volume (`pvc.yaml`) keeps the images pulled by jobs, so they are not pulled again after a restart.
- **Pod Security**: The pod runs as non-root user and group `1000` with the `RuntimeDefault` seccomp profile, using a service account (`serviceaccount.yaml`) without token mounting. The upstream chart offers no container-level security settings, and its init container has no resource limits.
- **Network Isolation**: A `CiliumNetworkPolicy` admits only the namespace and the node, because the runner accepts no incoming connections.
- **Automatic Restarts**: The `StatefulSet` carries `reloader.stakater.com/auto` so Stakater Reloader restarts it when the token secret changes.

> [!WARNING]
> The Docker daemon sidecar requires `privileged: true`, which the Pod Security Standards `baseline` and `restricted` profiles and the [Kyverno Policies](kyverno-policies.md) audit report as a violation. Run the runner in a dedicated namespace and use it only for repositories you trust, because a job can escape its container.

## Dependencies

- **Upstream Chart**: `actions`, pinned in [Chart.yaml](../../kubernetes/catalog/gitea-runner/Chart.yaml).
- **Git Service**: A [Gitea](gitea.md) instance with Actions enabled.
- **Secrets Provider**: [OpenBao](openbao.md) through [External Secrets](external-secrets.md).
- **Restarts**: [Reloader](reloader.md); add the namespace to its instance values.

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/gitea-runner/values.schema.json) and [values.yaml](../../kubernetes/catalog/gitea-runner/values.yaml).

Key configuration parameters:

- `actions.giteaRootURL`: URL under which the runner reaches Gitea; the default is the in-cluster service of an instance named `gitea` in the namespace `gitea`.
- `actions.statefulset.runner.config`: Runner configuration file; `runner.labels` in it decide which jobs the runner accepts.
- `actions.statefulset.runner` and `actions.statefulset.dind`: Image tag and `@sha256:` digest, and resources of the runner and the Docker daemon.
- `persistence`: Size and storage class of the image cache volume.
- `networkPolicy`: Enabled by default without a `port`; requires Cilium.

## Setup

Create a registration token in Gitea (`Site Administration`, `Actions`, `Runners`) and seed `secret/gitea-runner` as described in [Seed Application Secrets](openbao.md#seed-application-secrets) with this content:

```json
{
  "registration-token": "<REGISTRATION_TOKEN>"
}
```

The Gitea chart allows the namespace `gitea-runner` through `networkPolicy.allow`; for another namespace, add it to the values of the Gitea instance so the runner can reach Gitea on its web port.

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `workload`. The release name must be `gitea-runner`, because the values refer to resources named after it. Wait for the generated secret and the runner before using it:

```sh
kubectl wait -n <NAMESPACE> --for=condition=Ready externalsecret/<INSTANCE> --timeout=5m
kubectl rollout status -n <NAMESPACE> statefulset/<INSTANCE>-runner --timeout=10m
kubectl logs -n <NAMESPACE> <INSTANCE>-runner-0 -c runner
```

The log reports `Runner registered successfully`, and the runner appears in Gitea as `<INSTANCE>-runner-0`.

> [!NOTE]
> The registration happens once and is stored in the volume of the pod, so rotating the token in OpenBao does not affect a registered runner. To register again, delete the `data-runner-<INSTANCE>-runner-0` claim and restart the pod.
