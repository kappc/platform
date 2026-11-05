# kube-prometheus-stack

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Prometheus Operator monitoring stack with Grafana

## Requirements

| Repository                                         | Name                  | Version |
| -------------------------------------------------- | --------------------- | ------- |
| https://prometheus-community.github.io/helm-charts | kube-prometheus-stack | 92.17.0 |

## Values

| Key                                                                                                             | Type   | Default                           | Description |
| --------------------------------------------------------------------------------------------------------------- | ------ | --------------------------------- | ----------- |
| externalSecrets[0].data.admin-password                                                                          | string | `"grafana-admin-password"`        |             |
| externalSecrets[0].data.admin-user                                                                              | string | `"grafana-admin-username"`        |             |
| externalSecrets[0].name                                                                                         | string | `"grafana-admin"`                 |             |
| externalSecrets[0].remoteKey                                                                                    | string | `"monitoring"`                    |             |
| httpRoute.enabled                                                                                               | bool   | `true`                            |             |
| httpRoute.listener                                                                                              | string | `"http"`                          |             |
| httpRoute.path                                                                                                  | string | `"/"`                             |             |
| httpRoute.port                                                                                                  | int    | `80`                              |             |
| httpRoute.service                                                                                               | string | `"kube-prometheus-stack-grafana"` |             |
| kube-prometheus-stack.grafana.admin.existingSecret                                                              | string | `"grafana-admin"`                 |             |
| kube-prometheus-stack.grafana.admin.passwordKey                                                                 | string | `"admin-password"`                |             |
| kube-prometheus-stack.grafana.admin.userKey                                                                     | string | `"admin-user"`                    |             |
| kube-prometheus-stack.grafana.persistence.enabled                                                               | bool   | `true`                            |             |
| kube-prometheus-stack.grafana.persistence.size                                                                  | string | `"2Gi"`                           |             |
| kube-prometheus-stack.prometheus.prometheusSpec.retention                                                       | string | `"7d"`                            |             |
| kube-prometheus-stack.prometheus.prometheusSpec.retentionSize                                                   | string | `"6GB"`                           |             |
| kube-prometheus-stack.prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0]             | string | `"ReadWriteOnce"`                 |             |
| kube-prometheus-stack.prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage | string | `"8Gi"`                           |             |
| networkPolicy.enabled                                                                                           | bool   | `false`                           |             |
