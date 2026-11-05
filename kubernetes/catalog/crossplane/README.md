# crossplane

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Crossplane core control plane

## Requirements

| Repository                          | Name       | Version |
| ----------------------------------- | ---------- | ------- |
| https://charts.crossplane.io/stable | crossplane | 2.4.3   |

## Values

| Key                                                          | Type   | Default            | Description |
| ------------------------------------------------------------ | ------ | ------------------ | ----------- |
| crossplane.configuration.packages                            | list   | `[]`               |             |
| crossplane.function.packages                                 | list   | `[]`               |             |
| crossplane.podSecurityContextCrossplane.runAsNonRoot         | bool   | `true`             |             |
| crossplane.podSecurityContextCrossplane.seccompProfile.type  | string | `"RuntimeDefault"` |             |
| crossplane.podSecurityContextRBACManager.runAsNonRoot        | bool   | `true`             |             |
| crossplane.podSecurityContextRBACManager.seccompProfile.type | string | `"RuntimeDefault"` |             |
| crossplane.provider.packages                                 | list   | `[]`               |             |
| crossplane.replicas                                          | int    | `1`                |             |
| crossplane.securityContextCrossplane.capabilities.drop[0]    | string | `"ALL"`            |             |
| crossplane.securityContextRBACManager.capabilities.drop[0]   | string | `"ALL"`            |             |
