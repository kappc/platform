# loki

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.6.16](https://img.shields.io/badge/AppVersion-3.6.16-informational?style=flat-square)

Grafana Loki log aggregation engine in single-binary mode

## Requirements

| Repository                            | Name | Version |
| ------------------------------------- | ---- | ------- |
| https://grafana.github.io/helm-charts | loki | 7.5.0   |

## Values

| Key                                            | Type   | Default          | Description |
| ---------------------------------------------- | ------ | ---------------- | ----------- |
| httpRoute.enabled                              | bool   | `true`           |             |
| httpRoute.listener                             | string | `"http"`         |             |
| httpRoute.path                                 | string | `"/"`            |             |
| httpRoute.port                                 | int    | `80`             |             |
| httpRoute.service                              | string | `"loki-gateway"` |             |
| loki.backend.replicas                          | int    | `0`              |             |
| loki.chunksCache.enabled                       | bool   | `false`          |             |
| loki.deploymentMode                            | string | `"SingleBinary"` |             |
| loki.loki.auth_enabled                         | bool   | `false`          |             |
| loki.loki.commonConfig.replication_factor      | int    | `1`              |             |
| loki.loki.schemaConfig.configs[0].from         | string | `"2024-04-01"`   |             |
| loki.loki.schemaConfig.configs[0].index.period | string | `"24h"`          |             |
| loki.loki.schemaConfig.configs[0].index.prefix | string | `"index_"`       |             |
| loki.loki.schemaConfig.configs[0].object_store | string | `"filesystem"`   |             |
| loki.loki.schemaConfig.configs[0].schema       | string | `"v13"`          |             |
| loki.loki.schemaConfig.configs[0].store        | string | `"tsdb"`         |             |
| loki.loki.storage.type                         | string | `"filesystem"`   |             |
| loki.lokiCanary.enabled                        | bool   | `false`          |             |
| loki.read.replicas                             | int    | `0`              |             |
| loki.resultsCache.enabled                      | bool   | `false`          |             |
| loki.singleBinary.persistence.enabled          | bool   | `true`           |             |
| loki.singleBinary.persistence.size             | string | `"10Gi"`         |             |
| loki.singleBinary.replicas                     | int    | `1`              |             |
| loki.singleBinary.resources.limits.cpu         | string | `"1"`            |             |
| loki.singleBinary.resources.limits.memory      | string | `"1Gi"`          |             |
| loki.singleBinary.resources.requests.cpu       | string | `"100m"`         |             |
| loki.singleBinary.resources.requests.memory    | string | `"256Mi"`        |             |
| loki.test.enabled                              | bool   | `false`          |             |
| loki.write.replicas                            | int    | `0`              |             |
| networkPolicy.enabled                          | bool   | `false`          |             |
