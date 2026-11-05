# Cert-Manager Catalog Application

- [Cert-Manager Catalog Application](#cert-manager-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `cert-manager` catalog chart provides automated X.509 certificate provisioning, renewal, and management for Kubernetes workloads. It integrates with various certificate issuers (such as internal self-signed CAs, ACME/Let's Encrypt, and HashiCorp Vault / OpenBao).

## Architecture

The chart vendors the upstream Jetstack `cert-manager` chart:

- **Platform PKI**: Issues and rotates internal certificates, for example the OpenBao TLS certificates in [certificate.yaml](../../kubernetes/catalog/openbao/templates/certificate.yaml).

## Dependencies

- **Upstream Chart**: `cert-manager`, pinned in [Chart.yaml](../../kubernetes/catalog/cert-manager/Chart.yaml).

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/cert-manager/values.schema.json) and [values.yaml](../../kubernetes/catalog/cert-manager/values.yaml).

Key configuration parameters:

- `cert-manager.crds.enabled`: Enables automated installation and reconciliation of cert-manager CustomResourceDefinitions.
- `cert-manager.resources`: Explicit CPU and memory bounds for the core controller, webhook, CA injector, and startup API check components.

## Setup

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `infrastructure`, because other charts such as `openbao` request certificates.
