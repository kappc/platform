# Project Guidelines

Kubernetes GitOps Platform: Reusable `Helm` charts in `kubernetes/catalog/`, cluster inventory, instance descriptors, and `Argo CD` GitOps configuration in `kubernetes/clusters/<CLUSTER>/`. See [docs/README.md](../docs/README.md).

Scoped rules live in [.github/instructions/](instructions/).

## Structure

- `kubernetes/catalog/<CHART>/`: Reusable `Helm` charts. Upstream charts wrapped or platform-owned charts with pinned images, dependencies, and Kubernetes manifests (`Chart.yaml`, `values.yaml`, `templates/`).
- `kubernetes/clusters/<CLUSTER>/argocd/`: `Argo CD` configuration. Root `Application` (`root-application.yaml`), `ApplicationSet` (`applicationset.yaml`), and `AppProject` manifests in `projects/`.
- `kubernetes/clusters/<CLUSTER>/instances/<INSTANCE>/`: Instance deployment descriptors. `instance.yaml` specifies `application`, `argocd` (`project`, `rolloutGroup`), and `namespace`; the directory name is the `Application` and release name. Optional `values.yaml` holds only overrides that cannot be derived.
- `renovate.json`: `Renovate` configuration that updates chart dependencies, image tags and digests, and `pre-commit` hooks.
- Do not edit generated files or chart archives directly: `Chart.lock` is updated via `helm dependency update`, archives in `charts/` are ignored, `values.schema.json` is generated via `helm-schema`, and catalog `README.md` files are generated via `helm-docs`.

## Build and Test

Formatting, linting, and security checks are enforced by `pre-commit` and configured in repository root configuration files (`.yamllint.yaml`, `.markdownlint.yaml`, `.pre-commit-config.yaml`). Tasks are defined in [Taskfile.yaml](../Taskfile.yaml); the virtual environment lives in `.venv`. Run `task` or `pre-commit run --all-files` before finishing a change; it must pass.

- `helm dependency build kubernetes/catalog/<CHART>`: build dependencies for a catalog chart
- `helm lint kubernetes/catalog/<CHART>`: lint an individual catalog chart
- `task init`: create `.venv`, install dependencies, and install `pre-commit` hooks
- `task`, `task pre-commit:run`: run all `pre-commit` hooks configured in [.pre-commit-config.yaml](../.pre-commit-config.yaml)
- Enforced `pre-commit` hooks: `codespell`, `conventional-pre-commit`, `gitleaks`, `helm-docs-built`, `helm-schema`, `helmlint`, `markdownlint-cli2`, `mdformat`, and `yamllint`

## Conventions

- Write code, comments, and docs in English.
- Use 2 spaces indentation for YAML and Markdown.
- Keep lines within 120 characters in code, templates, and comments, but not in Markdown.
- Order deployment using rollout groups: `infrastructure`, `platform`, `workload`.
- Route HTTP traffic through `Gateway API` `HTTPRoute` referencing the `Envoy Gateway` parent; do not use Kubernetes `Ingress`.
- Set hostnames explicitly via `httpRoute.hostname` in instance values.
- Keep `values.yaml` of wrapper charts and instances to the keys that differ from upstream or catalog defaults.
- Protect stateful databases with `CloudNativePG` `Cluster` and `argocd.argoproj.io/sync-options: Prune=confirm`.
- Use `Stakater Reloader` annotations when workloads need automated rolling restarts upon `Secret` or `ConfigMap` updates.
- Update the relevant documentation in [docs/](../docs/README.md) when adding or modifying charts, instances, dependencies, or operational procedures.

## Dependencies

- Pin chart dependencies in `Chart.yaml` and commit the corresponding `Chart.lock`.
- Pin container images in catalog charts by tag and immutable sha256 digest (`image@sha256:...`), in a form that `renovate.json` can update.
- Pin `pre-commit` hook revisions in `.pre-commit-config.yaml`.
- Pin Python development tools in `requirements-dev.txt` with `==`.

## Git

- Branch from `main` and never commit directly to it; name branches `<TYPE>/<KEBAB_CASE_DESCRIPTION>` using the commit types below.
- Commit types: `build`, `chore`, `ci`, `docs`, `feat`, `fix`, `perf`, `refactor`, `revert`, `style`, `test`.
- Do not commit, push, or open a PR unless explicitly asked.
- Keep commits atomic: one logical change per commit, with matching manifests and docs.
- Mark breaking changes with `!` before the colon or with a `BREAKING CHANGE:` footer.
- Never bypass hooks (`--no-verify`), force-push, or rewrite published history.
- Write commit messages and PR titles as [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) (`<TYPE>[(<SCOPE>)][!]: <DESCRIPTION>`); the `commit-msg` hook enforces this.
- Write the description in lowercase imperative without a trailing period; add details in a body after a blank line.

## Security

- Never hardcode secrets, private keys, tokens, or passwords in Git; manage credentials through `OpenBao` (KV-v2 `secret/<APP>`) and `External Secrets Operator` (`ExternalSecret`).
- Follow least privilege for RBAC and `AppProject` definitions: restrict namespaces, cluster-scoped resources, and source repositories.
- Use explicit non-root user/group IDs and `seccompProfile: { type: RuntimeDefault }` in pod security contexts.
- Never run destructive `kubectl` commands, delete namespaces, or prune resources unless explicitly requested.
- Do not suppress findings of `codespell`, `gitleaks`, `yamllint`, or other linters without an explicit justifying comment.
