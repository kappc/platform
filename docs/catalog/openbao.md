# OpenBao Catalog Application

- [OpenBao Catalog Application](#openbao-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)
    - [Seed Application Secrets](#seed-application-secrets)
    - [Access the Web UI](#access-the-web-ui)

## Overview

The `openbao` catalog chart deploys OpenBao, an open-source, community-governed secret management engine based on HashiCorp Vault. It provides centralized storage for application tokens, passwords, certificates, and encryption keys with granular ACL policies and audit logging.

## Architecture

The chart bundles the upstream OpenBao Helm chart with platform PKI and secret store templates:

- **Integrated Raft Storage**: Single-node high availability mode with Raft storage on a persistent volume.
- **Internal TLS via cert-manager**: [issuer.yaml](../../kubernetes/catalog/openbao/templates/issuer.yaml) and [certificate.yaml](../../kubernetes/catalog/openbao/templates/certificate.yaml) create a private CA (`openbao-ca`) and the server certificate (`openbao-tls`).
- **ClusterSecretStore**: [clustersecretstore.yaml](../../kubernetes/catalog/openbao/templates/clustersecretstore.yaml) defines the shared `openbao` store for External Secrets (KV-v2 at `secret`, Kubernetes auth role `external-secrets`). Every application `ExternalSecret` references it. Only Git can create `ExternalSecret` resources, so the store has no namespace restriction unless `secretStore.allowedNamespaces` is set.
- **Internal Web UI**: The UI is enabled but only reachable through `kubectl port-forward`.

## Dependencies

- **Upstream Chart**: `openbao`, pinned in [Chart.yaml](../../kubernetes/catalog/openbao/Chart.yaml).
- **Certificate Provider**: [cert-manager](cert-manager.md) issues the TLS certificates.

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/openbao/values.schema.json) and [values.yaml](../../kubernetes/catalog/openbao/values.yaml).

Key configuration parameters:

- `openbao.server.dataStorage`: Size and storage class of the Raft volume.
- `secretStore.enabled`: Creates the `ClusterSecretStore`; enabled by default.
- `secretStore.allowedNamespaces`: Optional list of namespaces that may use the store; empty means every namespace.

## Setup

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `platform`, after cert-manager and External Secrets.

> [!IMPORTANT]
> Save the unseal keys and the root token outside the cluster. OpenBao must be unsealed again after every pod restart, and the application stays progressing while it is sealed.

Initialize and unseal OpenBao once from a shell in the pod (`kubectl exec -it -n <NAMESPACE> openbao-0 -- sh`):

```sh
export BAO_ADDR=https://localhost:8200
export BAO_CACERT=/openbao/ca/tls.crt
bao operator init -key-shares=5 -key-threshold=3
bao operator unseal
bao login
```

Run `bao operator unseal` with three different unseal keys. Then enable the KV-v2 engine and Kubernetes authentication, and create one read policy for all application secrets:

```sh
bao secrets enable -path=secret kv-v2
bao auth enable kubernetes
bao write auth/kubernetes/config kubernetes_host=https://kubernetes.default.svc
bao policy write external-secrets-read - <<'EOF'
path "secret/data/*" {
  capabilities = ["read"]
}
EOF
```

Finally, let External Secrets authenticate:

```sh
bao write auth/kubernetes/role/external-secrets \
  bound_service_account_names=external-secrets \
  bound_service_account_namespaces=<EXTERNAL_SECRETS_NAMESPACE> \
  bound_service_account_audiences=openbao \
  token_policies=external-secrets-read \
  token_ttl=1h
```

The chart grants the OpenBao service account `system:auth-delegator`, so leaving `token_reviewer_jwt` and `kubernetes_ca_cert` unset lets OpenBao use its projected token and CA. Use the root token for administration only.

> [!NOTE]
> One role and one policy serve every application, because External Secrets uses a single service account and a per-application policy on that role would not isolate anything: the token carries the union of all attached policies. Access control therefore rests on Git, where only reviewed `ExternalSecret` resources reach the cluster, and on separate paths per application (`secret/<APP>`). For stronger isolation, run one `SecretStore` and one role per namespace instead of the shared `ClusterSecretStore`.

### Seed Application Secrets

Never pass secret values as `key=value` arguments to `bao kv put`: they end up in the shell history and the process list. Put the values in a JSON file on encrypted local storage (mode `0600`, never committed) and let `bao` read it from stdin, which keeps a copy out of the pod. The command uses the token that `bao login` cached in the pod, so log in first:

```sh
kubectl exec -i -n <NAMESPACE> openbao-0 -- \
  env BAO_ADDR=https://localhost:8200 BAO_CACERT=/openbao/ca/tls.crt \
  bao kv put secret/<APP> - \
  < /secure/path/<APP>-secrets.json
```

Delete the local file afterwards. External Secrets retries while a value is missing, but the application's workloads only start once the generated Kubernetes `Secret` exists.

### Access the Web UI

The UI is only exposed through a `ClusterIP` service. After OpenBao is unsealed, forward it and sign in with an OpenBao token:

```sh
kubectl port-forward -n <NAMESPACE> svc/openbao-ui 8200:8200
```

Open `https://localhost:8200/ui/`. Keep the trailing slash, because `/ui` redirects to `/ui/`. Use `https://`; a plain HTTP request is rejected with "Client sent an HTTP request to an HTTPS server." The certificate is signed by the private CA, so browsers that do not trust it show a warning.
