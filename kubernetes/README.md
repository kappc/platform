# Kubernetes Platform

GitOps configuration for the `homelab` cluster lives here. Reusable Helm charts are in `catalog/`; cluster inventory, instance overrides, and Argo CD configuration are in `clusters/homelab/`.

Chart dependencies are pinned in `Chart.yaml` and `Chart.lock` and pulled from registries; generated chart archives are not committed. Images in platform-owned charts are pinned by tag and digest.

The Argo CD ApplicationSet creates one Application per inventory descriptor. RollingSync deploys `infrastructure`, then `platform`, then `workload`. Generated Applications prune resources removed from their charts.

## Contents

- [Bootstrap a cluster](#bootstrap)
- [Deploy and extend applications](#deploy-and-extend-applications)
- [Kyverno policies](#kyverno-policies)
- [Homer dashboard](#homer-dashboard)
- [OpenBao and External Secrets](#openbao-and-external-secrets)
- [Authentik](#authentik)
- [Nextcloud](#nextcloud)
- [Outline](#outline)
- [Observability](#observability)
- [Crossplane](#crossplane)
- [MetalLB](#metallb)
- [Shared secret and recovery notes](#shared-secret-and-recovery-notes)
- [Access Whoami](#accessing-whoami)
- [Validate changes](#validation)

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
kubectl apply -f kubernetes/clusters/homelab/argocd/root-application.yaml
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

The `root` Application recursively loads the AppProjects, ApplicationSet, and its own `root-application.yaml` from `clusters/homelab/argocd/`. The manual `kubectl apply` bootstraps it; afterward, Argo CD reconciles the root Application from Git like the other resources. AppProjects use sync wave `-1`; the ApplicationSet uses the default wave `0`. After bootstrap, make changes through Git and let Argo CD manage the releases.

To upgrade a chart dependency, update its version in the catalog `Chart.yaml`, run `helm dependency update` for that chart, and review and commit the resulting `Chart.lock`. Envoy Gateway CRDs stored in the upstream chart's `crds/` directory need to be upgraded separately; Helm does not upgrade them automatically.

## Deploy and extend applications

### Instance descriptors

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

### AppProjects

Add an AppProject manifest under `clusters/<cluster>/argocd/projects/` for each project. The ApplicationSet selects the project and rollout group from each descriptor. Keep project source repositories and cluster-scoped resource permissions as narrow as practical; AppProjects are policy boundaries, not namespaces.

## Kyverno policies

The [Kyverno policies catalog chart](./catalog/kyverno-policies/Chart.yaml) wraps the upstream [kyverno-policies chart](https://artifacthub.io/packages/helm/kyverno/kyverno-policies) at the same pinned version as the Kyverno controller. It enables the upstream Baseline Pod Security Standard (PSS) policies and defines platform policies as individual `ValidatingPolicy` templates in `catalog/kyverno-policies/templates/policies/`.

The custom policies report missing resource requests or limits and mutable or untagged images in Audit mode. Review Policy Reporter results before changing validation to `Deny`. Configure the shared action in the top-level `customPolicies` section of `catalog/kyverno-policies/values.yaml`; keep it aligned with the upstream `kyverno-policies.validationFailureAction` used by PSS policies.

To add a policy, add a separate `ValidatingPolicy` manifest under `catalog/kyverno-policies/templates/policies/`. The `platform` AppProject permits `ValidatingPolicy` resources.

## Homer dashboard

Homer is deployed in the `platform` rollout group at `http://homer.homelab.test`. Cluster-specific dashboard configuration, including apps and links, lives in `clusters/homelab/instances/homer/values.yaml`; edit its `dashboard.services` list to add or remove service links. Stakater Reloader is a separate `platform` catalog app, scoped to the `reloader` and `homer` namespaces. Homer opts in to reload only when its dashboard ConfigMap changes, so changing instance values restarts Homer without a checksum annotation. The image is pinned by release tag and digest in the catalog chart.

## OpenBao and External Secrets

### Shared architecture

Authentik and Nextcloud are separate applications and can be used or managed independently. Neither depends on the other. They share platform infrastructure: OpenBao and External Secrets for secret delivery, and the CloudNativePG operator for PostgreSQL management. Each app has its own PostgreSQL `Cluster`, database role, ExternalSecrets, OpenBao KV entry, and Kubernetes namespace. Outline is also an independent app; it uses Authentik only as its selected OIDC sign-in provider and has its own database, Redis, file storage, and secrets.

The homelab inventory installs cert-manager, External Secrets Operator, and MetalLB in the `infrastructure` rollout group. OpenBao, the CloudNativePG operator, Homer, Reloader, Crossplane, kube-prometheus-stack, and Authentik run in the `platform` group; Nextcloud and Outline run in the `workload` group. These rollout groups order deployment, not application dependencies. Operators use their standard namespaces (`cert-manager`, `external-secrets`, and `cnpg-system`). OpenBao owns one shared `ClusterSecretStore`, restricted to the `authentik`, `nextcloud`, `outline`, and `monitoring` namespaces.

Each CNPG `Cluster` creates a PostgreSQL server and its application's database. Its `DatabaseRole` declares the application's non-privileged login and gets its password from an ESO-managed Secret. Keeping a separate cluster per app aligns its credentials, storage, backup/restore, upgrades, and resource tuning with that app's lifecycle. Argo CD requires explicit confirmation before pruning a database cluster. One-instance clusters are appropriate for this single-node Minikube setup, not for high availability.

OpenBao has persistent single-node Raft storage and uses Kubernetes authentication for External Secrets. Initialize it once; after an OpenBao pod restart, unseal it again. The OpenBao app remains progressing while sealed, holding the platform rollout.

Before syncing Outline or kube-prometheus-stack, create the Outline OIDC client and seed their `secret/outline` and `secret/monitoring` entries as described below. External Secrets retries when a value is missing, but the workloads need those generated Kubernetes Secrets to start correctly.

### Access the OpenBao UI

The OpenBao UI is enabled but its Service is internal-only (`ClusterIP`). After OpenBao is initialized and unsealed, access it locally with:

```sh
kubectl port-forward -n openbao svc/openbao-ui 8200:8200
```

Then open `https://localhost:8200/ui/` and sign in with an OpenBao token. Use the trailing slash: `/ui` redirects to `/ui/`. The UI is not exposed through the Gateway.

Use `https://`, not `http://`; an HTTP request to this TLS endpoint returns “Client sent an HTTP request to an HTTPS server.” The certificate is signed by the cluster's private CA, so browsers that do not trust that CA may show a certificate warning.

### Initialize OpenBao and configure External Secrets

For the one-time bootstrap, open a shell in the pod:

```sh
kubectl exec -it -n openbao openbao-0 -- sh
```

Run the following inside the pod. Save the displayed unseal keys and root token securely outside the cluster; use three different unseal keys to unseal:

```sh
export BAO_ADDR=https://localhost:8200
export BAO_CACERT=/openbao/ca/tls.crt
bao operator init -key-shares=5 -key-threshold=3
bao operator unseal # Repeat three times with different unseal keys.
bao login
# Keep the root token for administration only.
bao secrets enable -path=secret kv-v2
bao auth enable kubernetes
bao write auth/kubernetes/config kubernetes_host=https://kubernetes.default.svc
bao policy write authentik-read - <<'EOF'
path "secret/data/authentik" {
  capabilities = ["read"]
}
EOF
bao policy write nextcloud-read - <<'EOF'
path "secret/data/nextcloud" {
  capabilities = ["read"]
}
EOF
bao policy write outline-read - <<'EOF'
path "secret/data/outline" {
  capabilities = ["read"]
}
EOF
bao policy write monitoring-read - <<'EOF'
path "secret/data/monitoring" {
  capabilities = ["read"]
}
EOF
bao write auth/kubernetes/role/external-secrets \
  bound_service_account_names=external-secrets \
  bound_service_account_namespaces=external-secrets \
  bound_service_account_audiences=openbao \
  token_policies=authentik-read,nextcloud-read,outline-read,monitoring-read \
  token_ttl=1h
```

The chart grants OpenBao's service account `system:auth-delegator`; leaving `token_reviewer_jwt` and `kubernetes_ca_cert` unset lets it use its projected token and CA. Each policy grants read access to one KV path. The shared External Secrets Kubernetes auth role includes the policies for each enabled app; the apps do not receive one another's credentials. On an existing installation, write or update each policy and update the auth role's `token_policies` list before syncing that app's ExternalSecrets.

## Authentik

Authentik uses its own external CNPG database; it does not rely on Nextcloud. Its chart configuration, database, and OpenBao entry are specific to the `authentik` namespace.

### Seed Authentik credentials

Authentik uses the external CNPG database instead of the chart's demo database. Create a separate temporary JSON file with mode `0600` on encrypted local storage (never in Git):

```json
{
  "secret-key": "REPLACE_WITH_LONG_RANDOM_SIGNING_KEY",
  "bootstrap-password": "REPLACE_WITH_GENERATED_INITIAL_ADMIN_PASSWORD",
  "db-username": "authentik",
  "postgres-password": "REPLACE_WITH_GENERATED_DATABASE_PASSWORD"
}
```

The secret key must be long, random, and kept stable across upgrades. The bootstrap password initializes Authentik's `akadmin` account; rotate it through Authentik after initial sign-in. Keep the PostgreSQL username as `authentik`.

Stream the file to the OpenBao pod from a second terminal:

```sh
kubectl exec -i -n openbao openbao-0 -- \
  sh -c 'umask 077; cat > /tmp/authentik-secrets.json' \
  < /secure/path/authentik-secrets.json
```

In the OpenBao shell:

```sh
bao kv put secret/authentik @/tmp/authentik-secrets.json
rm /tmp/authentik-secrets.json
```

Remove the local file when finished. The OpenBao policy and ClusterSecretStore must permit reads from the `authentik` namespace.

### Verify Authentik

After OpenBao and the CNPG operator are healthy, wait for Authentik's external secrets and database resources:

```sh
kubectl wait -n authentik \
  --for=condition=Ready externalsecret/authentik-config \
  externalsecret/authentik-db --timeout=5m
kubectl wait -n authentik \
  --for=condition=Ready cluster.postgresql.cnpg.io/authentik-db --timeout=10m
kubectl wait -n authentik \
  --for=condition=Ready databaserole.postgresql.cnpg.io/authentik-app --timeout=5m
```

Sign in to `http://authentik.homelab.test` as `akadmin` using the bootstrap password. The Gateway currently serves HTTP only; keep authentication traffic on a trusted local network until TLS is configured.

## Nextcloud

Nextcloud has its own database and credentials; it does not rely on Authentik.

### Seed Nextcloud credentials

To seed Nextcloud, create a temporary JSON file with mode `0600` on encrypted local storage (never in Git). Use this shape, replacing the password placeholders with unique generated passwords:

```json
{
  "admin-username": "admin",
  "admin-password": "REPLACE_WITH_GENERATED_ADMIN_PASSWORD",
  "db-username": "nextcloud",
  "db-password": "REPLACE_WITH_GENERATED_DATABASE_PASSWORD"
}
```

`admin-username` is the Nextcloud web administrator. `db-username` is the PostgreSQL login Nextcloud uses for its CNPG database and must be `nextcloud`. Keep the credentials file outside Git and remove both temporary copies after writing it to OpenBao.

From a second terminal, stream the file into the pod:

```sh
kubectl exec -i -n openbao openbao-0 -- \
  sh -c 'umask 077; cat > /tmp/nextcloud-secrets.json' \
  < /secure/path/nextcloud-secrets.json
```

Back in the OpenBao shell, write it to the KV store, remove the pod copy, and then remove the local file:

```sh
bao kv put secret/nextcloud @/tmp/nextcloud-secrets.json
rm /tmp/nextcloud-secrets.json
```

### Verify the Nextcloud deployment

Wait for the generated secrets and database before using Nextcloud:

```sh
kubectl wait -n nextcloud \
  --for=condition=Ready externalsecret/nextcloud-admin \
  externalsecret/nextcloud-db --timeout=5m
kubectl wait -n nextcloud \
  --for=condition=Ready cluster.postgresql.cnpg.io/nextcloud-db --timeout=10m
kubectl wait -n nextcloud \
  --for=condition=Ready databaserole.postgresql.cnpg.io/nextcloud-app --timeout=5m
```

The chart allows up to 10 minutes for startup so the image can complete first-install database setup before Kubernetes applies liveness checks. The CronJob runs as UID/GID 33, matching the `www-data` owner of Nextcloud's shared files.

### Access and rotate credentials

Nextcloud is available at `http://nextcloud.homelab.test`; map the hostname to the MetalLB Gateway address as described under [MetalLB](#metallb). For credential rotation, update the corresponding password in OpenBao and let External Secrets sync it. For the database password, also wait for CNPG to apply the new role password and update Nextcloud's stored database credentials before resuming the CronJob. Change the Nextcloud administrator password through Nextcloud's administration interface after updating its value in OpenBao.

## Outline

Outline is an independent knowledge base, deployed in the `workload` rollout group. It uses its own CNPG database, Redis instance, persistent local attachment volume, and OpenBao KV entry. Authentik is used only as its OIDC sign-in provider; Outline does not share Authentik's application data or database. The Gateway currently serves HTTP only, so this homelab configuration disables Outline's HTTPS redirect and should remain on a trusted local network until TLS is configured.

### Configure Authentik OIDC

In Authentik, create a confidential OAuth2/OpenID Connect provider and an application for Outline:

- Client ID: `outline`
- Redirect URI: `http://outline.homelab.test/auth/oidc.callback`
- Scopes: `openid`, `profile`, and `email`

Save the generated client secret in OpenBao as `oidc-client-secret`. The client authorization endpoint uses the browser-accessible Authentik host, while the token and user-info endpoints use Authentik's in-cluster service.

### Seed Outline credentials

Create a temporary JSON file with mode `0600` on encrypted local storage (never in Git):

```json
{
  "secret-key": "REPLACE_WITH_LONG_RANDOM_SECRET",
  "utils-secret": "REPLACE_WITH_DIFFERENT_LONG_RANDOM_SECRET",
  "oidc-client-secret": "REPLACE_WITH_AUTHENTIK_CLIENT_SECRET",
  "db-username": "outline",
  "db-password": "REPLACE_WITH_GENERATED_DATABASE_PASSWORD",
  "redis-password": "REPLACE_WITH_DIFFERENT_GENERATED_REDIS_PASSWORD"
}
```

Keep the `secret-key` and `utils-secret` stable. Stream the file to the OpenBao pod from a second terminal:

```sh
kubectl exec -i -n openbao openbao-0 -- \
  sh -c 'umask 077; cat > /tmp/outline-secrets.json' \
  < /secure/path/outline-secrets.json
```

In the OpenBao shell:

```sh
bao kv put secret/outline @/tmp/outline-secrets.json
rm /tmp/outline-secrets.json
```

Remove the local file when finished. Before using Outline, wait for the secrets and database:

```sh
kubectl wait -n outline \
  --for=condition=Ready externalsecret/outline-config \
  externalsecret/outline-db externalsecret/outline-redis --timeout=5m
kubectl wait -n outline \
  --for=condition=Ready cluster.postgresql.cnpg.io/outline-db --timeout=10m
kubectl wait -n outline \
  --for=condition=Ready databaserole.postgresql.cnpg.io/outline-app --timeout=5m
```

Outline is available at `http://outline.homelab.test`. Its local attachment PVC and database are not backups; arrange off-cluster backups before storing important notes or files.

## Observability

The `kube-prometheus-stack` catalog app installs Prometheus Operator, Prometheus, Alertmanager, and Grafana in the `monitoring` namespace. Prometheus retains seven days of metrics on an 8Gi PVC, and Grafana uses a separate 2Gi PVC. Grafana is exposed through the Gateway at `http://grafana.homelab.test`.

Seed the Grafana admin credentials in OpenBao at `secret/monitoring` using this JSON shape:

```json
{
  "grafana-admin-username": "admin",
  "grafana-admin-password": "REPLACE_WITH_GENERATED_ADMIN_PASSWORD"
}
```

Use the same secure temporary-file and `bao kv put` procedure as above, changing the filename to `monitoring-secrets.json` and the command to `bao kv put secret/monitoring @/tmp/monitoring-secrets.json`. Grafana's admin username and password are synchronized by External Secrets and are not stored in Helm values.

## Crossplane

Crossplane core is installed in `crossplane-system` in the `platform` rollout group. No Providers, Configurations, or Functions are installed; add them only when a specific infrastructure API is needed.

## MetalLB

MetalLB assigns LoadBalancer IPs from `192.168.49.240-192.168.49.250` and advertises them over L2 on Minikube's `eth0`. This pool is on the Docker driver's private bridge (`192.168.49.0/24`), so the IPs are intended for access from the host, not directly from other LAN devices. Reserve the range from other use. Envoy Gateway is pinned to `192.168.49.240`; its Service changes from NodePort `30080` to LoadBalancer port 80.

Map the application hostnames to `192.168.49.240` on the host running the browser (for example, in `/etc/hosts`). The URLs no longer include `:30080`. To serve other LAN devices, use a network/driver design that places the Minikube node and MetalLB address pool on a LAN-reachable subnet; the Docker bridge pool does not provide that reachability.

## Shared secret and recovery notes

ESO writes synced values into ordinary Kubernetes Secrets; External Secrets keeps credentials out of Git but does not itself encrypt Kubernetes API storage. Kubernetes Secrets may be stored unencrypted in etcd unless encryption at rest is configured.

This local setup uses Minikube's `standard` hostpath StorageClass, one PostgreSQL instance per app, and one OpenBao Raft member. It is not highly available, and these volumes are not backups. Configure and test off-cluster backups before storing important data, and provide TLS at the Gateway before exposing the applications beyond a trusted lab network.

## Accessing Whoami

Whoami is available at `http://whoami.homelab.test`. Map `whoami.homelab.test` to `192.168.49.240` on the host running the browser (for example, in `/etc/hosts`); see [MetalLB](#metallb).

## Validation

Run the repository validator to build dependencies, lint charts, and validate rendered instances:

```sh
python kubernetes/scripts/validate.py
```

Review rendered resources and the `Chart.lock` diff when changing charts or dependencies.
