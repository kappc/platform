# cilium-policies

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Cilium default-deny ingress and baseline policies

## Values

| Key                   | Type   | Default         | Description |
| --------------------- | ------ | --------------- | ----------- |
| allowRules            | list   | `[]`            |             |
| excludedNamespaces[0] | string | `"kube-system"` |             |
| sameNamespace         | list   | `[]`            |             |
