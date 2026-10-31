# Kubernetes Platform

This directory is the GitOps source for the `homelab` cluster. Application charts live under `applications/`; per-cluster inventory, AppProjects, and overrides live under `clusters/homelab/instances/` and `clusters/homelab/argocd/`.

Chart dependencies are pinned in each `Chart.yaml`/`Chart.lock` and pulled from OCI registries; chart archives are never committed. YAML manifests and values use the `.yaml` extension and begin with a YAML document separator. Helm's generated `Chart.lock` keeps its required filename.

Images defined directly in platform-owned charts are pinned by both a readable version tag and an immutable registry digest; update both together when upgrading an image. Upstream chart images are left to the upstream chart defaults and are not overridden in platform values.

Argo CD creates one Application per inventory descriptor and uses RollingSync to deploy the `platform` group before the `workload` group. RollingSync is enabled in Argo CD's Helm values and intentionally owns syncing generated Applications rather than combining with per-Application automated sync.

## Bootstrap

The homelab configuration uses the public repository `https://github.com/kappc/platform.git` on the `main` branch. Argo CD reads it over anonymous HTTPS, so no Git credentials are required. Ensure the repository is public and the Minikube cluster can reach GitHub.

Start Minikube and verify that kubectl targets the intended cluster before installing anything:

```sh
minikube start
kubectl config use-context minikube
kubectl cluster-info
```

Install the same pinned Argo CD chart and values that the Git-managed `argocd` application will reconcile:

```sh
helm dependency build kubernetes/applications/argocd
helm upgrade --install argocd kubernetes/applications/argocd \
  --namespace argocd \
  --create-namespace \
  -f kubernetes/applications/argocd/values.yaml

kubectl wait --for=condition=Established --timeout=120s \
  crd/appprojects.argoproj.io \
  crd/applications.argoproj.io \
  crd/applicationsets.argoproj.io
kubectl apply -f kubernetes/clusters/homelab/argocd/projects/argocd.yaml
kubectl apply -f kubernetes/clusters/homelab/argocd-root.yaml
```

To access the Argo CD UI locally, keep this port-forward running in a terminal:

```sh
kubectl port-forward -n argocd svc/argocd-server 8080:443
```

In another terminal, retrieve the initial admin password:

```sh
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 --decode
```

Sign in as `admin` at `https://localhost:8080`. The port-forward stops when you close the command or terminal. Change the initial password after the first login, then remove the `argocd-initial-admin-secret` Secret.

The bootstrap Helm install creates Argo CD; the root Application recursively loads the AppProjects and the ApplicationSet directly from the `argocd/` directory. AppProjects sync in wave `-4`, and the ApplicationSet in wave `-2`. The Envoy Gateway chart installs its Gateway API and Envoy Gateway CRDs as part of the generated `envoy-gateway` Application; Argo CD syncs CRDs before dependent custom resources in that application. The same chart also configures the controller and Gateway. Note that Helm does not upgrade CRDs stored in a chart's `crds/` directory during a chart version upgrade; follow Envoy Gateway's documented CRD upgrade procedure before upgrading the controller. The generated `argocd` Application uses the same wrapper chart, values, and release name. To upgrade Argo CD, update the `argo-cd` chart dependency version in `applications/argocd/Chart.yaml`, refresh and commit `applications/argocd/Chart.lock`, and merge the change. The generated Application then reconciles that chart version through RollingSync. For a new cluster, bootstrap from the version and values recorded in the repository.

After applying the root Application, let Argo CD own subsequent changes; do not run `helm upgrade` manually against the same release.

To update OCI dependencies and refresh lock files:

```sh
helm dependency update kubernetes/applications/argocd
helm dependency update kubernetes/applications/envoy-gateway
```

Helm pulls charts from the registries into a local cache or `charts/` directory as needed. Archives are ignored by Git and are not part of the application definitions.

## Inventory Fields and Projects

Each deployment instance groups its descriptor and cluster overrides together:

```text
clusters/homelab/instances/whoami/
├── instance.yaml
└── values.yaml
```

The `instance.yaml` descriptor separates deployment identity, destination, policy, and rollout group:

| Field | Meaning | Example |
| --- | --- | --- |
| `app` | Reusable chart definition under `applications/` | `whoami` |
| `instance` | Unique Argo CD Application and Helm release name | `whoami` or `whoami-internal` |
| `namespace` | Kubernetes namespace where that release deploys | `whoami` |
| `project` | Argo CD AppProject that constrains source, destination, and resource permissions | `platform` |
| `rolloutGroup` | RollingSync group for ordered deployment | `workload` |

For example, two `whoami` instances can use the same `app` while having distinct `instance`, `namespace`, and values files. The current groups are `platform` and `workload`; Argo CD and Envoy Gateway are in `platform`, while whoami is in `workload`. Cluster overrides use the conventional `values.yaml` filename beside the descriptor and are optional; if absent, only the chart's manifest-defined settings are used. Keep values files limited to settings that vary by instance or cluster; fixed workload details belong in the chart templates. The Envoy Gateway chart defaults its data-plane Service to `LoadBalancer`; the homelab instance overrides it to `NodePort` port `30080`. The chart's Gateway defaults to name `gateway`, GatewayClass `envoy-gateway`, and listener `http` on port 80. The whoami chart exposes image repository, tag and digest, `deployment.replicas`, resource requests/limits, and HTTPRoute settings (enabled state, parent Gateway references, hostname, and path). Its security context, probes, and container/service ports are fixed in the manifests. The app listens on the whoami image's default container port, 80. An AppProject is an Argo CD policy boundary, not a Kubernetes namespace; different projects can target the same namespace only when their destination rules permit it. Removing an instance descriptor removes its generated Application; its resource finalizer can delete the release's resources, so protect and back up persistent data before removal.

Add one manifest under `clusters/<cluster>/argocd/projects/` for every AppProject; the root Application recursively discovers these manifests. The generic ApplicationSet reads `project` and `rolloutGroup` from each inventory descriptor, so different tools can use different projects without separate ApplicationSets. The `platform` project allows namespaced applications in any namespace of the local cluster; keep its source repositories and cluster-scoped resource allowlist narrow. The included `argocd` project is reserved for the Argo CD control plane; `platform` is for platform services and workloads, including the Gateway API and Envoy Gateway CRDs. RollingSync currently places Argo CD and Envoy Gateway in the `platform` rollout group, followed by whoami in `workload`.

## Accessing Whoami

The Envoy Gateway chart creates a Gateway named `gateway` in `envoy-gateway-system`, using GatewayClass `envoy-gateway`. Its `http` listener accepts HTTPRoutes from any namespace on port 80. Whoami's HTTPRoute targets that Gateway and listener for `whoami.homelab.test`. The homelab instance exposes the generated Envoy proxy Service as a NodePort on port `30080`; map the hostname to the Minikube node address on the client (for example, in `/etc/hosts`) and browse to `http://whoami.homelab.test:30080`.

This initial Gateway is HTTP-only. If the cluster later provides a load balancer, change the Envoy proxy Service configuration in `applications/envoy-gateway/templates/envoyproxy.yaml`.

Envoy Gateway supports route-scoped external authorization and OIDC through its `SecurityPolicy` CRD. This repository does not deploy an authentication backend or policy yet.

## Validation

Build dependencies before linting the umbrella charts, then lint and render each application with the appropriate shared and instance values:

```sh
helm dependency build kubernetes/applications/argocd
helm dependency build kubernetes/applications/envoy-gateway
helm lint kubernetes/applications/argocd
helm lint kubernetes/applications/envoy-gateway
helm lint kubernetes/applications/whoami \
  --set httpRoute.hostname=whoami.validation.invalid
helm template whoami kubernetes/applications/whoami \
  --namespace whoami \
  -f kubernetes/applications/whoami/values.yaml \
  -f kubernetes/clusters/homelab/instances/whoami/values.yaml
```

Review rendered resources when changing chart values or dependencies, and review and commit the `Chart.lock` files when changing dependency versions.
