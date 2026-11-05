---
description: "Use when creating, modifying, or refactoring catalog charts in kubernetes/catalog/."
applyTo: "kubernetes/catalog/**"
---

# Catalog Guidelines

Charts in `kubernetes/catalog/` are reusable, self-contained components packaged as Helm charts. Upstream charts are vendored via chart dependencies, while custom applications are authored as native platform charts. Resources that charts share (database, secrets, route, network policy) are declared directly in chart templates without an external library.

## Structure

| File/Directory           | Responsibility                                                            |
| ------------------------ | ------------------------------------------------------------------------- |
| `Chart.lock`             | Pinned dependency lock file; always commit when dependencies are updated. |
| `Chart.yaml`             | Chart metadata, version, and pinned chart dependencies.                   |
| `charts/`                | Downloaded chart archives; ignored by Git.                                |
| `README.md`              | Chart documentation generated via `helm-docs`; do not edit manually.      |
| `templates/`             | Resource manifests and standard templates.                                |
| `templates/_helpers.tpl` | Native charts only: `<CHART>` helpers for labels and hostname.            |
| `values.schema.json`     | JSON schema for values generated via `helm-schema`; do not edit manually. |
| `values.yaml`            | Default configuration values for the chart.                               |

## Conventions

### Standard Resource Templates

- Add template files in `templates/` for the resources the chart requires:
  - `database.yaml`: CloudNativePG `Cluster`, `DatabaseRole`, and `ExternalSecret`.
  - `externalsecret.yaml`: application `ExternalSecret` resources.
  - `httproute.yaml`: Gateway API `HTTPRoute` referencing Envoy Gateway.
  - `networkpolicy.yaml`: namespace-wide `CiliumNetworkPolicy`.
- Enable resources through top-level values: `database.enabled`, `httpRoute`, `networkPolicy`, and `externalSecrets`. Set only values that differ from defaults.
- Disable upstream route, network policy, and database subcharts when the chart templates provide them.
- Native charts define `<CHART>.name`, `<CHART>.fullname`, `<CHART>.labels`, and `<CHART>.selectorLabels` in `_helpers.tpl`.
- Set hostnames explicitly via `httpRoute.hostname` in instance values.

### Manifests and Templates

- Ensure chart names match their directory names under `kubernetes/catalog/`.
- Native charts define `<CHART>.name` and `<CHART>.fullname` in `_helpers.tpl` and apply `<CHART>.labels` and `<CHART>.selectorLabels`; the standard labels are `app.kubernetes.io/name`, `app.kubernetes.io/instance`, `app.kubernetes.io/version`, and `helm.sh/chart`. Wrapper charts without platform-owned workloads omit the helpers and labels.
- Harden pods: `runAsNonRoot: true`, explicit UID/GID (e.g. `65532`), `seccompProfile: { type: RuntimeDefault }`, `allowPrivilegeEscalation: false`, `drop: ["ALL"]` capabilities, and `readOnlyRootFilesystem: true` when supported.
- Always set CPU and memory `requests` and `limits`; define `readinessProbe` and `livenessProbe` on HTTP workloads.
- Set `automountServiceAccountToken: false` on pods that do not call the Kubernetes API.
- Do not add `spec.description`, other explanatory fields, or `values.yaml` comments for network policies; the manifests and the chart document state the intent.
- Restart workloads on `Secret` or `ConfigMap` changes with `Stakater Reloader` annotations (e.g. `reloader.stakater.com/auto: "true"`).
- Keep lines within 120 characters; break long expressions with intermediate variables (e.g. `{{- $err := "..." }}`) or folded scalars (`>-`). Prefer inline `required` expressions and extract the message into a variable only to satisfy the line limit.

### Values and Dependencies

- Order root-level keys consistently in `values.yaml`:
  - Wrapper charts: platform resources first (`database`, `httpRoute`, `networkPolicy`, `externalSecrets`),
    followed by the upstream chart configuration (`<UPSTREAM>`).
  - Native charts: workload definition (`deployment`, `image`), platform resources (`database`, `httpRoute`,
    `networkPolicy`, `externalSecrets`), application configuration, `persistence`, and `resources`.
- Never store secrets or sensitive plaintext tokens in `values.yaml`.
- Keep `values.yaml` to the keys that differ from the upstream defaults; do not restate upstream defaults such as `imagePullPolicy`.
- Pin container images by repository, tag, and immutable digest in `values.yaml`, either as `repository`, `tag`, and `digest` keys or as `tag: <TAG>@sha256:<DIGEST>`, so that Renovate can update them; keep the repository explicit.
- Derive resource names from `.Release.Name`; when `values.yaml` has to hard-code a name, state the required release name in the chart's document.
- Add `# --` comments in `values.yaml` only for values whose purpose is not obvious from their name; do not add release-name or other explanatory comments.
- Generate `values.schema.json` using `helm-schema` and `README.md` using `helm-docs`; never modify them by hand.
- Pin upstream repository URLs and exact version ranges in `Chart.yaml` dependencies.
- Update dependencies using `helm dependency update kubernetes/catalog/<CHART>` and commit the resulting `Chart.lock`.

### Documentation

- Create or update `docs/catalog/<APPLICATION>.md` and the application index in `docs/catalog/README.md` when adding, modifying, or removing a catalog chart.
- Document architecture, prerequisites, and mandatory parameters; do not duplicate `values.yaml` content, which `values.schema.json` already describes.

## Validation

- Download pinned dependencies with `helm dependency build kubernetes/catalog/<CHART>`.
- Lint charts before committing using `helm lint kubernetes/catalog/<CHART>`.
- Render and inspect templates locally using `helm template <CHART> kubernetes/catalog/<CHART>`.
- Verify schemas and documentation using `pre-commit run helm-schema --all-files` and `pre-commit run helm-docs-built --all-files`.

## Example

```gotmpl
# kubernetes/catalog/<CHART>/templates/deployment.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "<CHART>.fullname" . }}
  labels:
    {{- include "<CHART>.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.deployment.replicas }}
  selector:
    matchLabels:
      {{- include "<CHART>.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "<CHART>.labels" . | nindent 8 }}
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 65532
        runAsGroup: 65532
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: app
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}@{{ .Values.image.digest }}"
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop:
                - ALL
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
```
