# vaultwarden

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Vaultwarden Bitwarden-compatible password manager

## Requirements

| Repository                            | Name        | Version |
| ------------------------------------- | ----------- | ------- |
| https://guerzon.github.io/vaultwarden | vaultwarden | 0.46.3  |

## Values

| Key                                                        | Type   | Default                                                                                   | Description |
| ---------------------------------------------------------- | ------ | ----------------------------------------------------------------------------------------- | ----------- |
| database.enabled                                           | bool   | `true`                                                                                    |             |
| database.image.digest                                      | string | `"sha256:dab846a58e8ca3c8872584ab2225ee93fb9e659a87c52e163fefae9275b46f51"`               |             |
| database.image.repository                                  | string | `"ghcr.io/cloudnative-pg/postgresql"`                                                     |             |
| database.image.tag                                         | string | `"17.7"`                                                                                  |             |
| database.resources.limits.cpu                              | string | `"1"`                                                                                     |             |
| database.resources.limits.memory                           | string | `"1Gi"`                                                                                   |             |
| database.resources.requests.cpu                            | string | `"100m"`                                                                                  |             |
| database.resources.requests.memory                         | string | `"256Mi"`                                                                                 |             |
| database.storage.size                                      | string | `"8Gi"`                                                                                   |             |
| externalSecrets[0].data.ADMIN_TOKEN                        | string | `"admin-token"`                                                                           |             |
| externalSecrets[0].name                                    | string | `"vaultwarden-config"`                                                                    |             |
| httpRoute.enabled                                          | bool   | `true`                                                                                    |             |
| httpRoute.listener                                         | string | `"https"`                                                                                 |             |
| httpRoute.path                                             | string | `"/"`                                                                                     |             |
| httpRoute.port                                             | int    | `80`                                                                                      |             |
| networkPolicy.enabled                                      | bool   | `true`                                                                                    |             |
| networkPolicy.port                                         | int    | `8080`                                                                                    |             |
| vaultwarden.adminToken.existingSecret                      | string | `"vaultwarden-config"`                                                                    |             |
| vaultwarden.adminToken.existingSecretKey                   | string | `"ADMIN_TOKEN"`                                                                           |             |
| vaultwarden.commonAnnotations."reloader.stakater.com/auto" | string | `"true"`                                                                                  |             |
| vaultwarden.database.dbName                                | string | `"vaultwarden"`                                                                           |             |
| vaultwarden.database.enableWal                             | bool   | `false`                                                                                   |             |
| vaultwarden.database.existingSecret                        | string | `"vaultwarden-db"`                                                                        |             |
| vaultwarden.database.host                                  | string | `"vaultwarden-db-rw"`                                                                     |             |
| vaultwarden.database.port                                  | string | `"5432"`                                                                                  |             |
| vaultwarden.database.type                                  | string | `"postgresql"`                                                                            |             |
| vaultwarden.image.repository                               | string | `"vaultwarden/server"`                                                                    |             |
| vaultwarden.image.tag                                      | string | `"1.37.4-alpine@sha256:19ea2b669945d842dadc3d500f2d6a795866a003330f59a47b9634658bae98bb"` |             |
| vaultwarden.podSecurityContext.fsGroup                     | int    | `1001`                                                                                    |             |
| vaultwarden.podSecurityContext.seccompProfile.type         | string | `"RuntimeDefault"`                                                                        |             |
| vaultwarden.resources.limits.cpu                           | string | `"500m"`                                                                                  |             |
| vaultwarden.resources.limits.memory                        | string | `"512Mi"`                                                                                 |             |
| vaultwarden.resources.requests.cpu                         | string | `"50m"`                                                                                   |             |
| vaultwarden.resources.requests.memory                      | string | `"128Mi"`                                                                                 |             |
| vaultwarden.securityContext.allowPrivilegeEscalation       | bool   | `false`                                                                                   |             |
| vaultwarden.securityContext.capabilities.drop[0]           | string | `"ALL"`                                                                                   |             |
| vaultwarden.securityContext.readOnlyRootFilesystem         | bool   | `true`                                                                                    |             |
| vaultwarden.securityContext.runAsGroup                     | int    | `1001`                                                                                    |             |
| vaultwarden.securityContext.runAsNonRoot                   | bool   | `true`                                                                                    |             |
| vaultwarden.securityContext.runAsUser                      | int    | `1001`                                                                                    |             |
| vaultwarden.signupsAllowed                                 | bool   | `false`                                                                                   |             |
| vaultwarden.storage.data.accessMode                        | string | `"ReadWriteOnce"`                                                                         |             |
| vaultwarden.storage.data.keepPvc                           | bool   | `true`                                                                                    |             |
| vaultwarden.storage.data.name                              | string | `"vaultwarden-data"`                                                                      |             |
| vaultwarden.storage.data.size                              | string | `"2Gi"`                                                                                   |             |
