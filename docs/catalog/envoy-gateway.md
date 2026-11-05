# Envoy Gateway Catalog Application

- [Envoy Gateway Catalog Application](#envoy-gateway-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `envoy-gateway` catalog chart deploys Envoy Gateway, an open-source implementation of the Kubernetes Gateway API. It manages Envoy proxy fleets and translates declarative `Gateway` and `HTTPRoute` resources into dynamic Envoy configurations.

## Architecture

The chart bundles the upstream `gateway-helm` chart alongside custom platform templates:

- **Gateway API CRDs**: Installs and reconciles the core Kubernetes Gateway API CustomResourceDefinitions.
- **GatewayClass Manifest**: Deploys a cluster-wide `GatewayClass` (`gatewayclass.yaml`) referencing `gateway.envoyproxy.io/gatewayclass-controller`.
- **Shared Gateway Resource**: Deploys a centralized `Gateway` (`gateway.yaml`) with an HTTP listener on port 80 that only admits routes from the namespaces allowed by `gateway.allowedRoutes` (default: the gateway's own namespace).
- **Optional HTTPS Listener**: With `gateway.tls.enabled`, the `Gateway` gets a TLS-terminating listener. [certificate.yaml](../../kubernetes/catalog/envoy-gateway/templates/certificate.yaml) requests its certificate from the issuer in `gateway.tls.certificate.issuerRef` or, when that is empty, creates a private CA and issues the certificate from it.
- **EnvoyProxy Service**: Configures the Envoy data plane as a `LoadBalancer` service (`envoyproxy.yaml`) so a load balancer such as MetalLB can assign its address.

## Dependencies

- **Upstream Chart**: `gateway-helm`, pinned in [Chart.yaml](../../kubernetes/catalog/envoy-gateway/Chart.yaml).
- **Certificate Provider**: [cert-manager](cert-manager.md), only when the HTTPS listener is enabled.

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/envoy-gateway/values.schema.json) and [values.yaml](../../kubernetes/catalog/envoy-gateway/values.yaml).

Key configuration parameters:

- `gateway-helm.crds.enabled`: Installs the core Kubernetes Gateway API CustomResourceDefinitions.
- `gateway.allowedRoutes`: Which namespaces may attach routes to the listeners; the default is the gateway's own namespace. A cluster that admits every namespace sets `from: All`, a stricter one sets `from: Selector` with a namespace selector and adds each new application namespace there.
- `gateway.tls`: Enables the HTTPS listener. Set `gateway.tls.listener.hostname` and certificate `dnsNames` in instance values; the certificate `secretName` and an existing `issuerRef` are optional.
- `envoyProxy.service`: A `LoadBalancer` service; instances set annotations such as `metallb.io/loadBalancerIPs` to pin the address.

## Setup

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `infrastructure`, so the `Gateway` exists before routes are applied. The certificate resources need the cert-manager CRDs, so the first sync may retry until cert-manager is ready.

Routes attach to the HTTP listener by default. To serve an application over HTTPS, set the `sectionName` of its route parent reference to the HTTPS listener and update the application's public URL, for example OIDC redirect URIs. Clients must trust the private CA when the chart creates one.

Helm does not upgrade the CRDs in the upstream chart's `crds/` directory. When you raise the chart version, upgrade those CRDs separately.
