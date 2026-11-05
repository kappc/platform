# Clusters Documentation

- [Clusters Documentation](#clusters-documentation)
  - [Overview](#overview)
  - [Directory Structure](#directory-structure)
  - [GitOps Flow](#gitops-flow)
  - [Instance Descriptors](#instance-descriptors)
  - [AppProjects](#appprojects)
  - [Cluster Inventory](#cluster-inventory)
  - [Add an Application](#add-an-application)
  - [Add a Cluster](#add-a-cluster)

## Overview

Each cluster in `kubernetes/clusters/<CLUSTER>/` declares its Argo CD configuration and one descriptor per deployed instance of a [catalog](../catalog/README.md) chart. The conventions are defined in [clusters.instructions.md](../../.github/instructions/clusters.instructions.md).

## Directory Structure

```text
kubernetes/clusters/<CLUSTER>/
├── argocd/
│   ├── root-application.yaml
│   ├── applicationset.yaml
│   └── projects/<PROJECT>.yaml
└── instances/<INSTANCE>/
    ├── instance.yaml
    └── values.yaml
```

## GitOps Flow

1. The `root` `Application` (`root-application.yaml`) syncs `argocd/` recursively: the `AppProject` manifests at sync wave `-1`, then the `ApplicationSet`, and finally itself.
1. The `ApplicationSet` (`applicationset.yaml`) reads every `instances/*/instance.yaml` with a Git file generator and creates one `Application` per instance.
1. Each `Application` is named after the instance directory, uses that name as the Helm release name, and renders the catalog chart named by `application` with the catalog `values.yaml` and, when present, `instances/<INSTANCE>/values.yaml`.
1. `RollingSync` deploys the `infrastructure`, `platform`, and `workload` rollout groups in this order. The groups order the rollout; they do not declare dependencies between applications.
1. `argocd.ignoreDifferences` in `instance.yaml` is passed to the `Application` for controller mutations that cause permanent diffs.
1. Sync operations retry with backoff, so an application that needs the CRDs of another chart in the same rollout group recovers once they exist.
1. The `ApplicationSet` and the `AppProject` manifests carry `argocd.argoproj.io/sync-options: Delete=confirm,Prune=confirm`, so removing a file from Git does not make `root` delete them until the deletion is confirmed manually.

## Instance Descriptors

Each instance lives in `instances/<INSTANCE>/`. The directory name is the `Application` name and the Helm release name.

| Field                      | Description                                                         |
| -------------------------- | ------------------------------------------------------------------- |
| `application`              | Catalog chart under `kubernetes/catalog/`.                          |
| `argocd.project`           | `AppProject` that constrains source, destination, and resources.    |
| `argocd.rolloutGroup`      | `RollingSync` stage: `infrastructure`, `platform`, or `workload`.   |
| `argocd.ignoreDifferences` | Optional `jqPathExpressions` or `jsonPointers` for permanent diffs. |
| `namespace`                | Destination namespace.                                              |

```yaml
# kubernetes/clusters/<CLUSTER>/instances/<INSTANCE>/instance.yaml
---
application: <CHART>
argocd:
  project: <PROJECT>
  rolloutGroup: <ROLLOUT_GROUP>
namespace: <INSTANCE>
```

The optional instance `values.yaml` contains only overrides that differ from the catalog defaults, such as `httpRoute.hostname`, the public URL of an application, or a storage class. Several instances can use the same catalog chart with different names, namespaces, and values, except for charts whose values refer to resources by release name; their catalog documents state the required name. Removing an instance removes its `Application` and, through pruning, its resources.

## AppProjects

An `AppProject` limits the source repositories, destination namespaces, and cluster-scoped kinds of the instances assigned to it. List namespaces and kinds explicitly instead of using wildcards, and add the namespace of a new instance to its project.

## Cluster Inventory

| Cluster               | Description                              |
| --------------------- | ---------------------------------------- |
| [homelab](homelab.md) | Single-node Minikube cluster with Cilium |

## Add an Application

1. Create `instances/<INSTANCE>/instance.yaml` with the chart, project, rollout group, and namespace.
1. Add the namespace to the `destinations` of its `AppProject`.
1. Seed `secret/<APP>` in OpenBao when the chart uses `externalSecrets` or a database, as described in its catalog document.
1. Add the namespace to the `reloader` instance values when the chart carries Reloader annotations.
1. When the chart needs a public URL, `httpRoute.hostname`, or other cluster-specific settings, add an instance `values.yaml` with only those keys.
1. When the cluster uses `cilium-policies`, add the namespace to `sameNamespace` unless the chart renders its own network policy, and add `allowRules` for cross-namespace flows.

## Add a Cluster

1. Copy `kubernetes/clusters/<EXISTING_CLUSTER>/` to `kubernetes/clusters/<CLUSTER>/`.
1. Update the repository URL and revision in `argocd/root-application.yaml` and `argocd/applicationset.yaml`, and the `path` patterns if the directory name changes.
1. Delete the instances the cluster does not need and adjust the remaining instance values that are tied to the environment, such as load balancer addresses and the `AppProject` namespaces.
1. Bootstrap Cilium and Argo CD, apply the `argocd` project and the root application, and initialize OpenBao as described in the [homelab runbook](homelab.md#bootstrap-runbook).
