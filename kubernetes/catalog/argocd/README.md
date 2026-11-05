# argocd

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Argo CD control plane

## Requirements

| Repository                       | Name    | Version |
| -------------------------------- | ------- | ------- |
| oci://ghcr.io/argoproj/argo-helm | argo-cd | 10.11.6 |

## Values

| Key                                                                        | Type   | Default  | Description |
| -------------------------------------------------------------------------- | ------ | -------- | ----------- |
| argo-cd.configs.params."applicationsetcontroller.enable.progressive.syncs" | string | `"true"` |             |
| argo-cd.dex.networkPolicy.create                                           | bool   | `true`   |             |
| argo-cd.global.networkPolicy.create                                        | bool   | `false`  |             |
| argo-cd.notifications.networkPolicy.create                                 | bool   | `true`   |             |
| argo-cd.redis.networkPolicy.create                                         | bool   | `true`   |             |
