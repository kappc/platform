# Homelab Cluster

- [Homelab Cluster](#homelab-cluster)
  - [Overview](#overview)
  - [Networking](#networking)
  - [Instances](#instances)
  - [AppProjects](#appprojects)
  - [Bootstrap Runbook](#bootstrap-runbook)
    - [Provision Minikube](#provision-minikube)
    - [Install Cilium](#install-cilium)
    - [Verify DNS](#verify-dns)
    - [Install Argo CD](#install-argo-cd)
    - [Access Argo CD](#access-argo-cd)
  - [Operations](#operations)
    - [Prepare OpenBao](#prepare-openbao)
    - [Reach the Applications](#reach-the-applications)
    - [Network Policies](#network-policies)
  - [Limitations](#limitations)

## Overview

The `homelab` cluster is a single-node Minikube cluster (Docker driver) managed from [kubernetes/clusters/homelab](kubernetes/clusters/homelab). Argo CD reads the `main` branch of the platform repository over anonymous HTTPS, so the repository must be public and reachable from the cluster. Instances that expose routes or services configure `httpRoute.hostname` with the desired domain (e.g. `<APP>.homelab.test`) in their instance values.

## Networking

- **CNI**: Cilium with native routing; Minikube's `kube-proxy` stays installed. Values are in [instances/cilium/values.yaml](../../kubernetes/clusters/homelab/instances/cilium/values.yaml).
- **Load Balancing**: MetalLB in Layer 2 mode serves the address range `192.168.49.240-192.168.49.250` on `eth0`.
- **Gateway**: The Envoy Gateway proxy `Service` is pinned to `192.168.49.240` and is of type `LoadBalancer`, so URLs carry no node port. All `HTTPRoute` hostnames are explicitly set in instance values, and the Gateway admits routes from every namespace (`gateway.allowedRoutes.namespaces.from: All`), so a new application needs no change here.
- **TLS**: The Gateway also has an HTTPS listener for `*.homelab.test`. Its certificate comes from a private CA (`gateway-ca`) that cert-manager creates in `envoy-gateway-system`. The application routes still attach to the HTTP listener.
- **DNS**: Map the hostnames to `192.168.49.240` in `/etc/hosts` or a local DNS server on the host running the browser.

The address range lives on the Docker driver's private bridge (`192.168.49.0/24`), so the addresses are reachable from the host but not from other LAN devices. Reserve the range from other use. Serving LAN devices requires a setup that places the Minikube node and the pool on a LAN-reachable subnet.

## Instances

| Instance                | Project          | Rollout Group    | Namespace              | Hostname                 |
| ----------------------- | ---------------- | ---------------- | ---------------------- | ------------------------ |
| `argocd`                | `argocd`         | `infrastructure` | `argocd`               |                          |
| `cert-manager`          | `infrastructure` | `infrastructure` | `cert-manager`         |                          |
| `cilium`                | `infrastructure` | `infrastructure` | `kube-system`          |                          |
| `cilium-policies`       | `infrastructure` | `infrastructure` | `kube-system`          |                          |
| `envoy-gateway`         | `infrastructure` | `infrastructure` | `envoy-gateway-system` |                          |
| `external-secrets`      | `infrastructure` | `infrastructure` | `external-secrets`     |                          |
| `kyverno`               | `infrastructure` | `infrastructure` | `kyverno`              |                          |
| `kyverno-policies`      | `infrastructure` | `infrastructure` | `kyverno`              |                          |
| `metallb`               | `infrastructure` | `infrastructure` | `metallb-system`       |                          |
| `authentik`             | `platform`       | `platform`       | `authentik`            | `authentik.homelab.test` |
| `cloudnative-pg`        | `platform`       | `platform`       | `cnpg-system`          |                          |
| `crossplane`            | `platform`       | `platform`       | `crossplane-system`    |                          |
| `homer`                 | `platform`       | `platform`       | `homer`                | `homer.homelab.test`     |
| `kube-prometheus-stack` | `platform`       | `platform`       | `monitoring`           | `grafana.homelab.test`   |
| `loki`                  | `platform`       | `platform`       | `monitoring`           | `loki.homelab.test`      |
| `openbao`               | `platform`       | `platform`       | `openbao`              |                          |
| `policy-reporter`       | `platform`       | `platform`       | `policy-reporter`      |                          |
| `reloader`              | `platform`       | `platform`       | `reloader`             |                          |
| `headscale`             | `workload`       | `workload`       | `headscale`            | `headscale.homelab.test` |
| `nextcloud`             | `workload`       | `workload`       | `nextcloud`            | `nextcloud.homelab.test` |
| `outline`               | `workload`       | `workload`       | `outline`              | `outline.homelab.test`   |
| `whoami`                | `workload`       | `workload`       | `whoami`               | `whoami.homelab.test`    |

Every instance uses the catalog application of the same name. See the [catalog](../catalog/README.md) for what each application does.

## AppProjects

| Project          | Destination Namespaces                                                                                           | Cluster-Scoped Kinds                                                                                                                                                                                                                 |
| ---------------- | ---------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `argocd`         | `argocd`                                                                                                         | `Namespace`, `CustomResourceDefinition`, `ClusterRole`, `ClusterRoleBinding`                                                                                                                                                         |
| `infrastructure` | `cert-manager`, `envoy-gateway-system`, `external-secrets`, `kube-system`, `kyverno`, `metallb-system`           | `Namespace`, webhook configurations, `ValidatingAdmissionPolicy` and binding, `CustomResourceDefinition`, `CiliumClusterwideNetworkPolicy`, `GatewayClass`, `ClusterPolicy`, `ValidatingPolicy`, `ClusterRole`, `ClusterRoleBinding` |
| `platform`       | `authentik`, `cnpg-system`, `crossplane-system`, `homer`, `monitoring`, `openbao`, `policy-reporter`, `reloader` | `Namespace`, `CustomResourceDefinition`, `ClusterSecretStore`, `ClusterRole`, `ClusterRoleBinding`                                                                                                                                   |
| `workload`       | `headscale`, `nextcloud`, `outline`, `whoami`                                                                    | `Namespace`                                                                                                                                                                                                                          |

## Bootstrap Runbook

The steps install the components that Argo CD depends on and then hand over to GitOps. Run them from the repository root.

### Provision Minikube

Start Minikube without a CNI, because Cilium provides networking:

```sh
minikube start --network-plugin=cni --cni=false --driver=docker
kubectl config use-context minikube
kubectl cluster-info
```

### Install Cilium

See [Cilium](../catalog/cilium.md#setup) for the rationale.

> [!WARNING]
> Do not use this procedure on a cluster that already runs workloads without planning the CNI migration first.

```sh
helm dependency build kubernetes/catalog/cilium
helm upgrade --install cilium kubernetes/catalog/cilium \
  --namespace kube-system \
  -f kubernetes/clusters/homelab/instances/cilium/values.yaml

kubectl rollout status daemonset/cilium -n kube-system --timeout=5m
kubectl rollout status deployment/cilium-operator -n kube-system --timeout=5m
kubectl -n kube-system exec ds/cilium -- cilium-dbg status
```

### Verify DNS

Argo CD must reach GitHub from inside the cluster. With the Docker driver, CoreDNS may forward to a Docker gateway address that pods cannot use as a resolver:

```sh
kubectl run dns-probe --image=busybox:1.36 --restart=Never --rm -i \
  --command -- nslookup github.com 10.96.0.10
```

> [!NOTE]
> If the lookup fails, change the `forward .` upstream in the CoreDNS `ConfigMap` to a resolver that pods can reach and restart CoreDNS. Repeat this after recreating the cluster.

### Install Argo CD

Install the same chart and values that the `argocd` instance later reconciles, then apply the control-plane project and the root application:

```sh
helm dependency build kubernetes/catalog/argocd
helm upgrade --install argocd kubernetes/catalog/argocd \
  --namespace argocd \
  --create-namespace \
  -f kubernetes/catalog/argocd/values.yaml

kubectl wait --for=condition=Established --timeout=120s \
  crd/appprojects.argoproj.io \
  crd/applications.argoproj.io \
  crd/applicationsets.argoproj.io

kubectl apply -f kubernetes/clusters/homelab/argocd/projects/argocd.yaml
kubectl apply -f kubernetes/clusters/homelab/argocd/root-application.yaml
```

The `root` application then creates the remaining projects and the `ApplicationSet`. From here on, change the cluster only through Git.

### Access Argo CD

```sh
kubectl port-forward -n argocd svc/argocd-server 8080:443
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 --decode
```

Sign in as `admin` at `https://localhost:8080` and change the initial password.

## Operations

### Prepare OpenBao

The `platform` rollout stays progressing until OpenBao is initialized and unsealed. Follow [OpenBao](../catalog/openbao.md#setup), which creates one read policy and the `external-secrets` role, and seed the `secret/<APP>` entry of each application that uses External Secrets as described in its catalog document: `authentik`, `nextcloud`, `outline`, and `monitoring`. The `openbao` instance restricts the `ClusterSecretStore` to these namespaces via `secretStore.allowedNamespaces`.

### Reach the Applications

Map the hostnames from the [instance table](#instances) to the gateway address:

```text
192.168.49.240  homer.homelab.test whoami.homelab.test authentik.homelab.test grafana.homelab.test nextcloud.homelab.test outline.homelab.test
```

The Gateway serves the applications over HTTP, so keep the cluster on a trusted network until their routes use the HTTPS listener.

### Network Policies

The `cilium-policies` instance denies ingress cluster-wide except in `kube-system`. It admits the node and the API server everywhere, traffic within the namespaces listed in its `sameNamespace` values, client traffic to the Envoy proxy listener ports (the gateway listener ports shifted by 10000 when below 1024), the gateway to Grafana, and External Secrets to OpenBao.

The `homer`, `whoami`, `authentik`, `nextcloud`, and `outline` charts render a `CiliumNetworkPolicy`; `kube-prometheus-stack` disables it and relies on the `cilium-policies` rules. The policy admits ingress from the namespace itself, the node (kubelet probes), and `envoy-gateway-system` on the application's port. Database pods additionally admit `cnpg-system` on the PostgreSQL and instance manager ports, and `authentik` admits `outline` for the OIDC token and user info calls. Egress is not restricted.

When an instance uses a new namespace, add it to `sameNamespace` in [instances/cilium-policies/values.yaml](../../kubernetes/clusters/homelab/instances/cilium-policies/values.yaml) unless its chart ships a `CiliumNetworkPolicy`, and add an `allowRules` entry for each cross-namespace flow. When another namespace needs to reach one of the applications above, add it to `networkPolicy.allow` in the catalog or instance values.

## Limitations

This setup is a local lab, not a production environment:

- External Secrets keeps credentials out of Git, but the synced Kubernetes `Secret` resources are stored in etcd, unencrypted unless encryption at rest is configured.
- Storage uses Minikube's `standard` hostpath `StorageClass`, one PostgreSQL instance per application, and one OpenBao Raft member. Nothing is highly available, and the volumes are not backups. Configure and test off-cluster backups before storing important data.
- Routes still use the HTTP listener. Switch them to the HTTPS listener and trust the private CA before exposing the applications beyond a trusted lab network.
