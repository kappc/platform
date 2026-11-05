# MetalLB Catalog Application

- [MetalLB Catalog Application](#metallb-catalog-application)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Setup](#setup)

## Overview

The `metallb` catalog chart deploys MetalLB, a network load-balancer implementation for bare-metal Kubernetes clusters. It allows standard Kubernetes `Services` of type `LoadBalancer` to receive external virtual IP addresses without relying on public cloud load balancer providers.

## Architecture

The chart bundles the upstream MetalLB controller and speaker alongside custom CRD manifests:

- **Layer 2 Mode**: Configured in Layer 2 (ARP) mode, which responds to ARP requests on the local network interface for allocated virtual IPs. BGP / FRR mode is disabled.
- **IPAddressPool Manifest**: Renders an `IPAddressPool` (`ipaddresspool.yaml`) from configurable address ranges.
- **L2Advertisement Manifest**: Renders an `L2Advertisement` (`l2advertisement.yaml`) that binds the pool to host network interfaces.
- **Controller Hardening**: The controller uses the `RuntimeDefault` seccomp profile. The speaker needs host networking and keeps the upstream defaults.

## Dependencies

- **Upstream Chart**: `metallb`, pinned in [Chart.yaml](../../kubernetes/catalog/metallb/Chart.yaml).

## Configuration

Complete schema definitions, property types, and defaults are defined in [values.schema.json](../../kubernetes/catalog/metallb/values.schema.json) and [values.yaml](../../kubernetes/catalog/metallb/values.yaml).

Key configuration parameters:

- `addressPool.enabled` and `addressPool.addresses`: Set in instance values to declare the address ranges.
- `l2Advertisement.enabled` and `l2Advertisement.interfaces`: Set in instance values to bind the pool to host network interfaces.

## Setup

Add an instance descriptor as described in [Instance Descriptors](../clusters/README.md#instance-descriptors). Recommended rollout group: `infrastructure`. Rendering the pool and advertisement fails with a `required` error while they are enabled without address ranges or interfaces.
