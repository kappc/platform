# Catalog Documentation

- [Catalog Documentation](#catalog-documentation)
  - [Overview](#overview)
  - [Platform Patterns](#platform-patterns)
    - [Standard Manifests in Catalog Charts](#standard-manifests-in-catalog-charts)
    - [Gateway API Routing](#gateway-api-routing)
    - [Stateful Storage with CloudNativePG](#stateful-storage-with-cloudnativepg)
    - [Secret Delivery with OpenBao](#secret-delivery-with-openbao)
    - [Automatic Restarts with Reloader](#automatic-restarts-with-reloader)
    - [Network Isolation with Cilium](#network-isolation-with-cilium)
  - [Applications](#applications)
  - [Maintain a Chart](#maintain-a-chart)
  - [Update Dependencies](#update-dependencies)

## Overview

The catalog in `kubernetes/catalog/` contains reusable Helm charts that are independent of any cluster. Cluster-specific values live in the instance descriptors described in the [Clusters Documentation](../clusters/README.md).

1. **Vendored Wrappers**: Charts that declare an upstream chart as a pinned dependency in `Chart.yaml` and add platform defaults.
1. **Native Charts**: Charts authored in this repository, for example `homer` and `whoami`.

The conventions for authoring charts (labels, pod hardening, image pinning, resources, probes) are defined in [catalog.instructions.md](../../.github/instructions/catalog.instructions.md).

## Platform Patterns

### Standard Manifests in Catalog Charts

Charts directly declare their required platform resources: a database, `ExternalSecret` resources, an `HTTPRoute`, and a `CiliumNetworkPolicy`. Hostnames are set explicitly via `httpRoute.hostname` in instance values.

### Gateway API Routing

Charts expose HTTP services with an `HTTPRoute` that references the shared Envoy Gateway listener. Kubernetes `Ingress` is not used.

### Stateful Storage with CloudNativePG

Applications that need PostgreSQL get their own `Cluster`, annotated with `argocd.argoproj.io/sync-options: Prune=confirm`, and a `DatabaseRole` whose password comes from an External Secrets-managed `Secret`.

### Secret Delivery with OpenBao

Charts create `ExternalSecret` resources that reference the shared `openbao` `ClusterSecretStore`. The values live in OpenBao at `secret/<APP>`, and one read policy on the `external-secrets` role covers all of them. See [OpenBao](openbao.md).

### Automatic Restarts with Reloader

Workloads that must restart when a `Secret` or `ConfigMap` changes use Stakater Reloader annotations. See [Reloader](reloader.md).

### Network Isolation with Cilium

Ingress is denied by default for the whole cluster by the [Cilium Policies](cilium-policies.md) chart. Charts render a `CiliumNetworkPolicy` for their namespace that admits the namespace itself, the node (kubelet probes), the gateway on the application port, and, with a database, the CloudNativePG operator. `networkPolicy.allow` lists further namespaces, for example OIDC clients. Egress is not restricted. All of this needs Cilium and is enabled by default; set `networkPolicy.enabled: false` on other CNIs.

## Applications

| Application                                       | Type    | Purpose                                                |
| ------------------------------------------------- | ------- | ------------------------------------------------------ |
| [argocd](argocd.md)                               | Wrapper | GitOps control plane                                   |
| [authentik](authentik.md)                         | Wrapper | Identity provider with its own database                |
| [cert-manager](cert-manager.md)                   | Wrapper | Certificate management                                 |
| [cilium](cilium.md)                               | Wrapper | CNI                                                    |
| [cilium-policies](cilium-policies.md)             | Native  | Cluster-wide default-deny ingress and baseline rules   |
| [cloudnative-pg](cloudnative-pg.md)               | Wrapper | PostgreSQL operator                                    |
| [crossplane](crossplane.md)                       | Wrapper | Infrastructure control plane core                      |
| [envoy-gateway](envoy-gateway.md)                 | Wrapper | Gateway API implementation and shared `Gateway`        |
| [external-secrets](external-secrets.md)           | Wrapper | Synchronizes external secrets into Kubernetes          |
| [firefly-iii](firefly-iii.md)                     | Wrapper | Personal finance manager with its own database         |
| [gitea](gitea.md)                                 | Wrapper | Git service with its own database                      |
| [gitea-runner](gitea-runner.md)                   | Wrapper | Gitea Actions runner with a Docker daemon              |
| [headscale](headscale.md)                         | Native  | Open-source Tailscale control plane                    |
| [homer](homer.md)                                 | Native  | Service dashboard                                      |
| [kube-prometheus-stack](kube-prometheus-stack.md) | Wrapper | Prometheus, Alertmanager, and Grafana                  |
| [kyverno](kyverno.md)                             | Wrapper | Policy engine                                          |
| [kyverno-policies](kyverno-policies.md)           | Wrapper | Pod Security Standards and platform policies           |
| [loki](loki.md)                                   | Wrapper | Log aggregation engine in single-binary mode           |
| [mail-archiver](mail-archiver.md)                 | Native  | Email archive with its own database                    |
| [metallb](metallb.md)                             | Wrapper | Bare-metal load balancer                               |
| [nextcloud](nextcloud.md)                         | Wrapper | File sharing and collaboration with its own database   |
| [openbao](openbao.md)                             | Wrapper | Secret store and shared `ClusterSecretStore`           |
| [outline](outline.md)                             | Wrapper | Knowledge base with its own database, Redis, and OIDC  |
| [pgadmin](pgadmin.md)                             | Wrapper | Web administration tool for PostgreSQL                 |
| [policy-reporter](policy-reporter.md)             | Wrapper | Kyverno policy report UI                               |
| [reloader](reloader.md)                           | Wrapper | Restarts workloads on `Secret` and `ConfigMap` changes |
| [sonarqube](sonarqube.md)                         | Wrapper | Code quality analysis with its own database            |
| [vaultwarden](vaultwarden.md)                     | Wrapper | Password manager with its own database                 |
| [whoami](whoami.md)                               | Native  | HTTP test service for gateway routing                  |

## Maintain a Chart

Update the pinned dependency version in `Chart.yaml`, then refresh the lock file, review the `Chart.lock` diff, and commit both:

```sh
helm dependency update kubernetes/catalog/<CHART>
```

Build the pinned dependencies and lint the chart before committing:

```sh
helm dependency build kubernetes/catalog/<CHART>
helm lint kubernetes/catalog/<CHART>
```

Render the chart with the instance values to check an instance, for example:

```sh
helm template <INSTANCE> kubernetes/catalog/<CHART> \
  -f kubernetes/clusters/<CLUSTER>/instances/<INSTANCE>/values.yaml
```

## Update Dependencies

[Renovate](https://docs.renovatebot.com/) is configured in [renovate.json](../../renovate.json). It opens a weekly pull request for each outdated item:

- **Chart Dependencies**: The `dependencies` of every `Chart.yaml`. Renovate refreshes the `Chart.lock` and bumps the patch version of the catalog chart.
- **Container Images**: Images in `values.yaml` files and in the library defaults, written as `repository`, `tag`, and `digest` or as `tag: <TAG>@sha256:<DIGEST>`. Renovate updates the tag and the digest together.
- **Hooks**: The `pre-commit` hook revisions.

Major updates wait for approval on the dependency dashboard. Keep images in one of the two formats above, otherwise Renovate cannot update them.
