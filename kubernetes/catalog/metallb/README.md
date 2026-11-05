# metallb

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

MetalLB load balancer controller and address pool

## Requirements

| Repository                        | Name    | Version |
| --------------------------------- | ------- | ------- |
| https://metallb.github.io/metallb | metallb | 0.16.1  |

## Values

| Key                                                    | Type   | Default            | Description |
| ------------------------------------------------------ | ------ | ------------------ | ----------- |
| addressPool.addresses                                  | list   | `[]`               |             |
| addressPool.enabled                                    | bool   | `false`            |             |
| addressPool.name                                       | string | `"default"`        |             |
| l2Advertisement.enabled                                | bool   | `false`            |             |
| l2Advertisement.interfaces                             | list   | `[]`               |             |
| l2Advertisement.name                                   | string | `"default"`        |             |
| metallb.controller.replicas                            | int    | `1`                |             |
| metallb.controller.resources.limits.cpu                | string | `"250m"`           |             |
| metallb.controller.resources.limits.memory             | string | `"256Mi"`          |             |
| metallb.controller.resources.requests.cpu              | string | `"25m"`            |             |
| metallb.controller.resources.requests.memory           | string | `"64Mi"`           |             |
| metallb.controller.securityContext.seccompProfile.type | string | `"RuntimeDefault"` |             |
| metallb.frrk8s.enabled                                 | bool   | `false`            |             |
| metallb.speaker.frr.enabled                            | bool   | `false`            |             |
| metallb.speaker.resources.limits.cpu                   | string | `"250m"`           |             |
| metallb.speaker.resources.limits.memory                | string | `"256Mi"`          |             |
| metallb.speaker.resources.requests.cpu                 | string | `"25m"`            |             |
| metallb.speaker.resources.requests.memory              | string | `"64Mi"`           |             |
