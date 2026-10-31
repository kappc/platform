# Kubernetes Platform

This directory contains the GitOps configuration for the `homelab` cluster. Reusable charts are in `catalog/`; cluster inventory, overrides, and Argo CD configuration are in `clusters/homelab/`.

Chart dependencies are pinned in `Chart.yaml` and `Chart.lock` and pulled from registries; generated chart archives are not committed. Images in platform-owned charts are pinned by tag and digest.

The ApplicationSet creates one Argo CD Application per inventory descriptor. RollingSync deploys `infrastructure`, then `platform`, then `workload`; generated Applications prune resources removed from their charts.

## Bootstrap

The homelab configuration uses the public repository `https://github.com/kappc/platform.git` on the `main` branch. Argo CD reads it over anonymous HTTPS, so no Git credentials are required. Ensure the repository is public and the Minikube cluster can reach GitHub.

For a fresh cluster, start Minikube without installing its default CNI; Cilium will provide networking. Verify that kubectl targets the intended cluster before installing anything:

```sh
minikube start --network-plugin=cni --cni=false --driver=docker
kubectl config use-context minikube
kubectl cluster-info
```

Install Cilium before Argo CD. It provides the CNI while Minikube's kube-proxy continues handling Kubernetes Services. The catalog disables Cilium's kube-proxy replacement and eBPF masquerading; Cilium still uses eBPF for its core networking datapath. The homelab overrides use native routing, set the pod CIDR and API endpoint, and run one operator replica for the single-node Minikube cluster. Do not use this bootstrap procedure on a cluster with workloads without planning the CNI migration.

```sh
helm dependency build kubernetes/catalog/cilium
helm upgrade --install cilium kubernetes/catalog/cilium \
  --namespace kube-system \
  -f kubernetes/clusters/homelab/instances/cilium/values.yaml

kubectl rollout status daemonset/cilium -n kube-system --timeout=5m
kubectl rollout status deployment/cilium-operator -n kube-system --timeout=5m
```

Verify that Cilium is healthy before installing Argo CD. Leave Minikube's kube-proxy installed:

```sh
kubectl -n kube-system exec ds/cilium -- cilium-dbg status
```

Verify public DNS from a pod before bootstrapping Argo CD. With Minikube's Docker driver, CoreDNS may forward to the Docker gateway (`192.168.49.1`), which may not be reachable as a DNS resolver from pods:

```sh
kubectl run dns-probe --image=busybox:1.36 --restart=Never --rm -i \
  --command -- nslookup github.com 10.96.0.10
```

If resolution fails, change CoreDNS's `forward .` upstream to a resolver reachable from pods and restart CoreDNS. This Minikube-managed change must be repeated after recreating the cluster.

Install the same pinned Argo CD chart and values that the Git-managed `argocd` application will reconcile:

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
kubectl apply -f kubernetes/clusters/homelab/argocd-root.yaml
```

The chart disables Argo CD NetworkPolicies globally because its defaults block kubelet health probes in this Cilium setup. Policies remain enabled for Dex, notifications, and Redis; the application-controller and repo-server have no ingress NetworkPolicy isolation.

To access the Argo CD UI locally, keep this port-forward running in a terminal:

```sh
kubectl port-forward -n argocd svc/argocd-server 8080:443
```

In another terminal, retrieve the initial admin password:

```sh
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 --decode
```

Sign in as `admin` at `https://localhost:8080` and change the initial password. The port-forward stops when you close the command.

The root Application loads the AppProjects and ApplicationSet from `clusters/homelab/argocd/`. AppProjects use sync wave `-1`; the ApplicationSet uses the default wave `0`. After bootstrap, make changes through Git and let Argo CD manage the releases.

To upgrade a chart dependency, update its version in the catalog `Chart.yaml`, run `helm dependency update` for that chart, and review and commit the resulting `Chart.lock`. Envoy Gateway CRDs stored in the upstream chart's `crds/` directory need to be upgraded separately; Helm does not upgrade them automatically.

## Inventory Fields and Projects

Each deployment instance groups its descriptor and cluster overrides together:

```text
clusters/homelab/instances/whoami/
├── instance.yaml
└── values.yaml
```

The `instance.yaml` descriptor selects a catalog application, destination namespace, and Argo CD deployment settings:

| Field | Meaning | Example |
| --- | --- | --- |
| `application` | Catalog entry under `catalog/` | `whoami` |
| `argocd.name` | Unique Argo CD Application and Helm release name | `whoami` or `whoami-internal` |
| `argocd.project` | Argo CD AppProject that constrains source, destination, and resource permissions | `platform` |
| `argocd.rolloutGroup` | RollingSync group for ordered deployment | `workload` |
| `namespace` | Kubernetes namespace where that release deploys | `whoami` |

```yaml
---
application: whoami
argocd:
  name: whoami
  project: platform
  rolloutGroup: workload
namespace: whoami
```

Multiple instances may use the same catalog application with distinct Argo CD names, namespaces, and values. Cluster-specific values are optional; keep them limited to settings that vary by instance. Removing an instance descriptor also removes its Application, and pruning can delete its resources.

Add an AppProject manifest under `clusters/<cluster>/argocd/projects/` for each project. The ApplicationSet selects the project and rollout group from each descriptor. Keep project source repositories and cluster-scoped resource permissions as narrow as practical; AppProjects are policy boundaries, not namespaces.

Kyverno policies report missing resource requests or limits and mutable or untagged images in audit mode. Review Policy Reporter results before changing a policy to enforce mode; configure policy actions and exclusions in `catalog/kyverno-policies/values.yaml`.

## Accessing Whoami

Whoami is available at `http://whoami.homelab.test:30080`. Map `whoami.homelab.test` to the Minikube node address on the client (for example, in `/etc/hosts`). The homelab Envoy proxy Service uses NodePort `30080`.

## Validation

Run the repository validator to build dependencies, lint charts, and validate rendered instances:

```sh
python kubernetes/scripts/validate.py
```

Review rendered resources and the `Chart.lock` diff when changing charts or dependencies.
