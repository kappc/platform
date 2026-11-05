# whoami

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.12.0](https://img.shields.io/badge/AppVersion-v1.12.0-informational?style=flat-square)

Whoami HTTP test service

## Values

| Key                       | Type   | Default                                                                     | Description |
| ------------------------- | ------ | --------------------------------------------------------------------------- | ----------- |
| deployment.replicas       | int    | `1`                                                                         |             |
| httpRoute.enabled         | bool   | `true`                                                                      |             |
| httpRoute.listener        | string | `"http"`                                                                    |             |
| httpRoute.path            | string | `"/"`                                                                       |             |
| httpRoute.port            | int    | `80`                                                                        |             |
| image.digest              | string | `"sha256:c4717a8d1f0134a7444e24f881160e033991f23027c6c5a9a3f8fd22e70d1d44"` |             |
| image.repository          | string | `"traefik/whoami"`                                                          |             |
| image.tag                 | string | `"v1.12.0"`                                                                 |             |
| networkPolicy.enabled     | bool   | `true`                                                                      |             |
| networkPolicy.port        | int    | `80`                                                                        |             |
| resources.limits.cpu      | string | `"100m"`                                                                    |             |
| resources.limits.memory   | string | `"64Mi"`                                                                    |             |
| resources.requests.cpu    | string | `"10m"`                                                                     |             |
| resources.requests.memory | string | `"16Mi"`                                                                    |             |
