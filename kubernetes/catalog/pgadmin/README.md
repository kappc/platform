# pgadmin

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

pgAdmin web administration tool for PostgreSQL

## Requirements

| Repository             | Name     | Version |
| ---------------------- | -------- | ------- |
| https://helm.runix.net | pgadmin4 | 1.70.4  |

## Values

| Key                                                        | Type   | Default                                                                          | Description |
| ---------------------------------------------------------- | ------ | -------------------------------------------------------------------------------- | ----------- |
| externalSecrets[0].data.password                           | string | `"admin-password"`                                                               |             |
| externalSecrets[0].name                                    | string | `"pgadmin-config"`                                                               |             |
| httpRoute.enabled                                          | bool   | `true`                                                                           |             |
| httpRoute.listener                                         | string | `"http"`                                                                         |             |
| httpRoute.path                                             | string | `"/"`                                                                            |             |
| httpRoute.port                                             | int    | `80`                                                                             |             |
| networkPolicy.enabled                                      | bool   | `true`                                                                           |             |
| networkPolicy.port                                         | int    | `8080`                                                                           |             |
| pgadmin4.containerPorts.http                               | int    | `8080`                                                                           |             |
| pgadmin4.containerSecurityContext.allowPrivilegeEscalation | bool   | `false`                                                                          |             |
| pgadmin4.containerSecurityContext.capabilities.drop[0]     | string | `"ALL"`                                                                          |             |
| pgadmin4.containerSecurityContext.enabled                  | bool   | `true`                                                                           |             |
| pgadmin4.containerSecurityContext.readOnlyRootFilesystem   | bool   | `true`                                                                           |             |
| pgadmin4.containerSecurityContext.runAsNonRoot             | bool   | `true`                                                                           |             |
| pgadmin4.containerSecurityContext.seccompProfile.type      | string | `"RuntimeDefault"`                                                               |             |
| pgadmin4.env.email                                         | string | `"admin@example.com"`                                                            |             |
| pgadmin4.existingSecret                                    | string | `"pgadmin-config"`                                                               |             |
| pgadmin4.fullnameOverride                                  | string | `"pgadmin"`                                                                      |             |
| pgadmin4.image.repository                                  | string | `"dpage/pgadmin4"`                                                               |             |
| pgadmin4.image.tag                                         | string | `"9.18@sha256:c332c5f6dfba995d9ebc4af261d93506d6876085d712eaaa3defc8dd1a3f26de"` |             |
| pgadmin4.networkPolicy.enabled                             | bool   | `false`                                                                          |             |
| pgadmin4.persistentVolume.size                             | string | `"2Gi"`                                                                          |             |
| pgadmin4.podAnnotations."reloader.stakater.com/auto"       | string | `"true"`                                                                         |             |
| pgadmin4.resources.limits.cpu                              | string | `"500m"`                                                                         |             |
| pgadmin4.resources.limits.memory                           | string | `"512Mi"`                                                                        |             |
| pgadmin4.resources.requests.cpu                            | string | `"50m"`                                                                          |             |
| pgadmin4.resources.requests.memory                         | string | `"256Mi"`                                                                        |             |
| pgadmin4.serviceAccount.create                             | bool   | `true`                                                                           |             |
| pgadmin4.test.enabled                                      | bool   | `false`                                                                          |             |
