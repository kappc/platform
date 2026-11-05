# Kyverno Policies Catalog Application

- [Kyverno Policies Catalog Application](#kyverno-policies-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `kyverno-policies` catalog chart packages upstream Pod Security Standard (PSS) policies alongside platform-specific validating admission policies. It audits and enforces container security, resource allocation, and supply chain constraints across all workloads in the cluster.

## Architecture

The chart combines the upstream Kyverno policy suite with custom platform `ValidatingPolicy` templates:

- **Pod Security Standards**: Enables the upstream policies for the configured `podSecurityStandard` profile.
- **Custom Platform Policies**:
  - `disallow-argocd-default-project` ([disallow-argocd-default-project.yaml](../../kubernetes/catalog/kyverno-policies/templates/policies/disallow-argocd-default-project.yaml)): Requires Argo CD applications to target a designated `AppProject` instead of `default`.
  - `disallow-default-namespace` ([disallow-default-namespace.yaml](../../kubernetes/catalog/kyverno-policies/templates/policies/disallow-default-namespace.yaml)): Disallows scheduling workloads into the `default` namespace.
  - `disallow-latest-tag` ([disallow-latest-tag.yaml](../../kubernetes/catalog/kyverno-policies/templates/policies/disallow-latest-tag.yaml)): Requires a non-`latest` tag or a digest on container and init container images.
  - `require-pod-probes` ([require-pod-probes.yaml](../../kubernetes/catalog/kyverno-policies/templates/policies/require-pod-probes.yaml)): Requires at least one liveness, readiness, or startup probe on workload containers.
  - `require-pod-requests-limits` ([require-pod-requests-limits.yaml](../../kubernetes/catalog/kyverno-policies/templates/policies/require-pod-requests-limits.yaml)): Requires CPU and memory requests and limits.

## Dependencies

- **Upstream Chart**: `kyverno-policies`, pinned in [Chart.yaml](../../kubernetes/catalog/kyverno-policies/Chart.yaml) at the same version as the Kyverno controller.
- **Runtime Engine**: The [Kyverno](kyverno.md) controller.

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/kyverno-policies/values.schema.json) and [values.yaml](../../kubernetes/catalog/kyverno-policies/values.yaml).

Key configuration parameters:

- `kyverno-policies.podSecurityStandard`: Upstream Pod Security Standard profile.
- `kyverno-policies.validationFailureAction`: Action for the upstream policies (`Audit` or `Enforce`).
- `customPolicies.validationFailureAction`: Action for the platform policies; keep it aligned with the upstream setting. Review [Policy Reporter](policy-reporter.md) results before switching from `Audit` to `Enforce`.

## Setup

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `infrastructure`, alongside the Kyverno controller. To add a policy, add a `ValidatingPolicy` template under `templates/policies/`; the instance's `AppProject` must allow `ValidatingPolicy`.
