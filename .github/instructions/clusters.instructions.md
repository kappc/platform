---
description: "Use when creating or modifying cluster inventory, instance descriptors, Argo CD applications, or AppProjects in kubernetes/clusters/."
applyTo: "kubernetes/clusters/**"
---

# Cluster Guidelines

Cluster configurations in `kubernetes/clusters/` declare environment-specific inventory, Argo CD GitOps definitions, and instance deployments.

## Structure

| File/Directory                       | Responsibility                                                                                        |
| ------------------------------------ | ----------------------------------------------------------------------------------------------------- |
| `argocd/applicationset.yaml`         | `ApplicationSet` generator producing `Application` resources from `instances/*/instance.yaml`.        |
| `argocd/projects/<PROJECT>.yaml`     | `AppProject` resources enforcing source, destination, and resource boundaries.                        |
| `argocd/root-application.yaml`       | Root `Application` bootstrapping projects, `ApplicationSet`, and itself.                              |
| `instances/<INSTANCE>/instance.yaml` | Deployment descriptor declaring catalog chart, `Argo CD` release settings, and destination namespace. |
| `instances/<INSTANCE>/values.yaml`   | Optional instance values overriding catalog defaults; only what cannot be derived or cluster domain.  |

## Conventions

### AppProjects and GitOps Configuration

- Set annotation `argocd.argoproj.io/sync-wave: "-1"` on `AppProject` manifests so projects exist before `ApplicationSet` generation.
- Set annotation `argocd.argoproj.io/sync-options: Delete=confirm,Prune=confirm` on `AppProject` and `ApplicationSet` manifests so removing a file from Git cannot make the root `Application` delete them without a manual confirmation.
- Restrict `sourceRepos` to the platform repository URL and `destinations` to permitted namespaces and server URLs (`https://kubernetes.default.svc`).
- Restrict `clusterResourceWhitelist` by explicitly enumerating allowed kinds; do not grant wildcard cluster-scoped permissions.
- Apply `resources-finalizer.argocd.argoproj.io` and configure `CreateNamespace=true`, `Prune=true`, `RespectIgnoreDifferences=true`, and `ServerSideApply=true` in the `ApplicationSet`.

### Instance Descriptors

- Represent each deployed application instance by a single directory under `instances/<INSTANCE>/`.
- Declare `application` (matching `catalog/<CHART>`), `argocd` (`project`, `rolloutGroup`), and target `namespace` in `instance.yaml`.
- Name the instance directory after the application unless several instances of one chart exist; the `ApplicationSet` uses the directory name as `Application` name and Helm release name and reads `instances/<INSTANCE>/values.yaml` from it.
- Assign `argocd.project` to an existing `AppProject` that permits the instance's namespace and cluster-scoped resource kinds.
- Assign `argocd.rolloutGroup` to one of the `RollingSync` stages, applied in this order:
  - `infrastructure`: foundational components that other stages depend on (e.g. networking, certificates, secret delivery, admission control, gateways).
  - `platform`: shared services, controllers, operators, and observability.
  - `workload`: user-facing applications and tenant workloads.
- Keep instance `values.yaml` minimal and delete it when empty: specify `httpRoute.hostname` when the application exposes a route, and include values that cannot be derived (e.g. public application URLs, load balancer addresses, storage classes, sizes). Move a value into the catalog when every cluster needs it. Order root-level keys to mirror their order in the catalog chart's `values.yaml`.
- Configure `argocd.ignoreDifferences` in `instance.yaml` using `jqPathExpressions` or `jsonPointers` when controller mutations create persistent diffs.
- Ingress is denied cluster-wide by the `cilium-policies` instance; add the namespace of every new instance to its `sameNamespace` list (unless the chart renders its own network policy) and add `allowRules` for cross-namespace flows.
- Add the namespace of every new instance to the destinations of its `AppProject`, and to the `reloader` instance values when the chart uses Reloader annotations.
- Never commit secrets in instance `values.yaml`; before syncing an instance, seed its secrets in `OpenBao` at `secret/<APP>`. The single `external-secrets-read` policy already covers all paths.

### Documentation

- Create or update `docs/clusters/<CLUSTER>.md` and the inventory tables in `docs/clusters/README.md` when adding, modifying, or removing a cluster, instance, or GitOps configuration.

## Validation

- Verify that the `<INSTANCE>` directory name is the intended release name and that `argocd.project` references an existing `AppProject`.
- Lint manifests using `pre-commit run yamllint --all-files`.
- Render an instance locally using `helm template <INSTANCE> kubernetes/catalog/<CHART> -n <NAMESPACE> -f kubernetes/clusters/<CLUSTER>/instances/<INSTANCE>/values.yaml`; omit the `-f` flag when the instance has no values.

## Example

```yaml
# kubernetes/clusters/<CLUSTER>/instances/<INSTANCE>/instance.yaml
---
application: <CHART>
argocd:
  project: <PROJECT>
  rolloutGroup: <ROLLOUT_GROUP>
namespace: <INSTANCE>
```

```yaml
# kubernetes/clusters/<CLUSTER>/instances/<INSTANCE>/values.yaml
---
global:
  domain: <DOMAIN>

<CHART>:
  config:
    url: https://<INSTANCE>.<DOMAIN>
```
