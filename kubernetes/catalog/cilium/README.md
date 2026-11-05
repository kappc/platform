# cilium

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Cilium CNI for Kubernetes networking

## Requirements

| Repository                  | Name   | Version |
| --------------------------- | ------ | ------- |
| oci://quay.io/cilium/charts | cilium | 1.20.4  |

## Values

| Key                         | Type | Default | Description |
| --------------------------- | ---- | ------- | ----------- |
| cilium.bpf.masquerade       | bool | `false` |             |
| cilium.kubeProxyReplacement | bool | `false` |             |
