# homer

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v26.08.3](https://img.shields.io/badge/AppVersion-v26.08.3-informational?style=flat-square)

Homer service dashboard

## Values

| Key                       | Type   | Default                                                                     | Description |
| ------------------------- | ------ | --------------------------------------------------------------------------- | ----------- |
| dashboard.footer          | bool   | `false`                                                                     |             |
| dashboard.header          | bool   | `true`                                                                      |             |
| dashboard.theme           | string | `"default"`                                                                 |             |
| deployment.replicas       | int    | `1`                                                                         |             |
| httpRoute.enabled         | bool   | `true`                                                                      |             |
| httpRoute.listener        | string | `"http"`                                                                    |             |
| httpRoute.path            | string | `"/"`                                                                       |             |
| httpRoute.port            | int    | `80`                                                                        |             |
| image.digest              | string | `"sha256:febc8967c9f7648ec37633ef3ae1ec90dbe8b7c46fecab80299f08f05be7ecb6"` |             |
| image.repository          | string | `"b4bz/homer"`                                                              |             |
| image.tag                 | string | `"v26.08.3"`                                                                |             |
| networkPolicy.enabled     | bool   | `true`                                                                      |             |
| networkPolicy.port        | int    | `8080`                                                                      |             |
| resources.limits.cpu      | string | `"100m"`                                                                    |             |
| resources.limits.memory   | string | `"128Mi"`                                                                   |             |
| resources.requests.cpu    | string | `"10m"`                                                                     |             |
| resources.requests.memory | string | `"32Mi"`                                                                    |             |
