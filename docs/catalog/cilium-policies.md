# Cilium Policies Catalog Application

- [Cilium Policies Catalog Application](#cilium-policies-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `cilium-policies` catalog chart denies ingress to all pods of a cluster by default and adds the allow rules that the platform itself needs. Applications then open only the traffic they require, usually through the `CiliumNetworkPolicy` resources of their own charts.

## Architecture

The chart is a native platform chart that renders only `CiliumClusterwideNetworkPolicy` resources ([policies.yaml](../../kubernetes/catalog/cilium-policies/templates/policies.yaml)):

- **Default Deny**: One policy selects every pod outside `excludedNamespaces` and admits only the node (`host`, `remote-node`) for kubelet probes and the API server (`kube-apiserver`) for admission webhooks. A pod that is selected by a policy with an ingress section denies all ingress that no policy admits. System namespaces such as `kube-system` stay open because they serve cluster-wide traffic like DNS.
- **Same-Namespace Rules**: One policy per entry of `sameNamespace` admits traffic between the pods of that namespace.
- **Allow Rules**: One policy per entry of `allowRules` admits traffic from namespaces or entities, optionally limited to pod labels and TCP ports.

Egress is not restricted.

## Dependencies

- **Chart Type**: Native platform chart without upstream dependencies.
- **CNI**: Cilium, which provides the `CiliumClusterwideNetworkPolicy` CRD.

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/cilium-policies/values.schema.json) and [values.yaml](../../kubernetes/catalog/cilium-policies/values.yaml).

Key configuration parameters:

- `excludedNamespaces`: Namespaces that stay open.
- `sameNamespace`: Namespaces whose pods may reach each other. Instances list every namespace that does not ship its own `CiliumNetworkPolicy`.
- `allowRules`: Cross-namespace and entity rules for the platform, for example the gateway reaching a dashboard or an operator reaching its secret store.

## Setup

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors) in the `infrastructure` rollout group, after Cilium. The project must allow `CiliumClusterwideNetworkPolicy` as a cluster-scoped kind.

> [!IMPORTANT]
> Ingress is denied for every namespace that is not excluded. Before a new application goes live, add its namespace to `sameNamespace` or give its chart a `CiliumNetworkPolicy`, and add an `allowRules` entry for every cross-namespace flow. Otherwise the application stays unreachable.

To find denied traffic, watch the drops on the node:

```sh
kubectl -n kube-system exec ds/cilium -- cilium-dbg monitor --type drop
```
