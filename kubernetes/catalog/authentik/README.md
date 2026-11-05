# authentik

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Authentik identity provider

## Requirements

| Repository                    | Name      | Version  |
| ----------------------------- | --------- | -------- |
| https://charts.goauthentik.io | authentik | 2026.8.5 |

## Values

| Key                                                                | Type   | Default                                                                     | Description |
| ------------------------------------------------------------------ | ------ | --------------------------------------------------------------------------- | ----------- |
| authentik.authentik.existingSecret.secretName                      | string | `"authentik-config"`                                                        |             |
| authentik.global.env[0].name                                       | string | `"AUTHENTIK_POSTGRESQL__HOST"`                                              |             |
| authentik.global.env[0].value                                      | string | `"authentik-db-rw"`                                                         |             |
| authentik.global.env[1].name                                       | string | `"AUTHENTIK_POSTGRESQL__NAME"`                                              |             |
| authentik.global.env[1].value                                      | string | `"authentik"`                                                               |             |
| authentik.global.env[2].name                                       | string | `"AUTHENTIK_POSTGRESQL__USER"`                                              |             |
| authentik.global.env[2].value                                      | string | `"authentik"`                                                               |             |
| authentik.server.containerSecurityContext.allowPrivilegeEscalation | bool   | `false`                                                                     |             |
| authentik.server.containerSecurityContext.capabilities.drop[0]     | string | `"ALL"`                                                                     |             |
| authentik.server.resources.limits.cpu                              | string | `"1"`                                                                       |             |
| authentik.server.resources.limits.memory                           | string | `"1Gi"`                                                                     |             |
| authentik.server.resources.requests.cpu                            | string | `"100m"`                                                                    |             |
| authentik.server.resources.requests.memory                         | string | `"512Mi"`                                                                   |             |
| authentik.server.securityContext.runAsGroup                        | int    | `1000`                                                                      |             |
| authentik.server.securityContext.runAsNonRoot                      | bool   | `true`                                                                      |             |
| authentik.server.securityContext.runAsUser                         | int    | `1000`                                                                      |             |
| authentik.server.securityContext.seccompProfile.type               | string | `"RuntimeDefault"`                                                          |             |
| authentik.worker.containerSecurityContext.allowPrivilegeEscalation | bool   | `false`                                                                     |             |
| authentik.worker.containerSecurityContext.capabilities.drop[0]     | string | `"ALL"`                                                                     |             |
| authentik.worker.resources.limits.cpu                              | string | `"1"`                                                                       |             |
| authentik.worker.resources.limits.memory                           | string | `"1Gi"`                                                                     |             |
| authentik.worker.resources.requests.cpu                            | string | `"100m"`                                                                    |             |
| authentik.worker.resources.requests.memory                         | string | `"512Mi"`                                                                   |             |
| authentik.worker.securityContext.runAsGroup                        | int    | `1000`                                                                      |             |
| authentik.worker.securityContext.runAsNonRoot                      | bool   | `true`                                                                      |             |
| authentik.worker.securityContext.runAsUser                         | int    | `1000`                                                                      |             |
| authentik.worker.securityContext.seccompProfile.type               | string | `"RuntimeDefault"`                                                          |             |
| database.enabled                                                   | bool   | `true`                                                                      |             |
| database.image.digest                                              | string | `"sha256:dab846a58e8ca3c8872584ab2225ee93fb9e659a87c52e163fefae9275b46f51"` |             |
| database.image.repository                                          | string | `"ghcr.io/cloudnative-pg/postgresql"`                                       |             |
| database.image.tag                                                 | string | `"17.7"`                                                                    |             |
| database.resources.limits.cpu                                      | string | `"1"`                                                                       |             |
| database.resources.limits.memory                                   | string | `"1Gi"`                                                                     |             |
| database.resources.requests.cpu                                    | string | `"100m"`                                                                    |             |
| database.resources.requests.memory                                 | string | `"256Mi"`                                                                   |             |
| database.storage.size                                              | string | `"8Gi"`                                                                     |             |
| externalSecrets[0].data.AUTHENTIK_BOOTSTRAP_PASSWORD               | string | `"bootstrap-password"`                                                      |             |
| externalSecrets[0].data.AUTHENTIK_POSTGRESQL\_\_PASSWORD           | string | `"db-password"`                                                             |             |
| externalSecrets[0].data.AUTHENTIK_SECRET_KEY                       | string | `"secret-key"`                                                              |             |
| externalSecrets[0].name                                            | string | `"authentik-config"`                                                        |             |
| httpRoute.enabled                                                  | bool   | `true`                                                                      |             |
| httpRoute.listener                                                 | string | `"http"`                                                                    |             |
| httpRoute.path                                                     | string | `"/"`                                                                       |             |
| httpRoute.port                                                     | int    | `80`                                                                        |             |
| httpRoute.service                                                  | string | `"authentik-server"`                                                        |             |
| networkPolicy.allow[0]                                             | string | `"outline"`                                                                 |             |
| networkPolicy.enabled                                              | bool   | `true`                                                                      |             |
| networkPolicy.port                                                 | int    | `9000`                                                                      |             |
