# nextcloud

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Nextcloud file sharing and collaboration

## Requirements

| Repository                       | Name      | Version |
| -------------------------------- | --------- | ------- |
| https://nextcloud.github.io/helm | nextcloud | 9.4.1   |

## Values

| Key                                                                | Type   | Default                                                                     | Description |
| ------------------------------------------------------------------ | ------ | --------------------------------------------------------------------------- | ----------- |
| database.enabled                                                   | bool   | `true`                                                                      |             |
| database.image.digest                                              | string | `"sha256:dab846a58e8ca3c8872584ab2225ee93fb9e659a87c52e163fefae9275b46f51"` |             |
| database.image.repository                                          | string | `"ghcr.io/cloudnative-pg/postgresql"`                                       |             |
| database.image.tag                                                 | string | `"17.7"`                                                                    |             |
| database.resources.limits.cpu                                      | string | `"1"`                                                                       |             |
| database.resources.limits.memory                                   | string | `"1Gi"`                                                                     |             |
| database.resources.requests.cpu                                    | string | `"100m"`                                                                    |             |
| database.resources.requests.memory                                 | string | `"256Mi"`                                                                   |             |
| database.storage.size                                              | string | `"8Gi"`                                                                     |             |
| externalSecrets[0].data.nextcloud-password                         | string | `"admin-password"`                                                          |             |
| externalSecrets[0].data.nextcloud-username                         | string | `"admin-username"`                                                          |             |
| externalSecrets[0].name                                            | string | `"nextcloud-admin"`                                                         |             |
| httpRoute.enabled                                                  | bool   | `true`                                                                      |             |
| httpRoute.listener                                                 | string | `"http"`                                                                    |             |
| httpRoute.path                                                     | string | `"/"`                                                                       |             |
| httpRoute.port                                                     | int    | `8080`                                                                      |             |
| networkPolicy.enabled                                              | bool   | `true`                                                                      |             |
| networkPolicy.port                                                 | int    | `80`                                                                        |             |
| nextcloud.cronjob.cronjob.resources.limits.cpu                     | string | `"250m"`                                                                    |             |
| nextcloud.cronjob.cronjob.resources.limits.memory                  | string | `"256Mi"`                                                                   |             |
| nextcloud.cronjob.cronjob.resources.requests.cpu                   | string | `"50m"`                                                                     |             |
| nextcloud.cronjob.cronjob.resources.requests.memory                | string | `"128Mi"`                                                                   |             |
| nextcloud.cronjob.cronjob.securityContext.allowPrivilegeEscalation | bool   | `false`                                                                     |             |
| nextcloud.cronjob.cronjob.securityContext.capabilities.drop[0]     | string | `"ALL"`                                                                     |             |
| nextcloud.cronjob.cronjob.securityContext.runAsGroup               | int    | `33`                                                                        |             |
| nextcloud.cronjob.cronjob.securityContext.runAsNonRoot             | bool   | `true`                                                                      |             |
| nextcloud.cronjob.cronjob.securityContext.runAsUser                | int    | `33`                                                                        |             |
| nextcloud.cronjob.cronjob.securityContext.seccompProfile.type      | string | `"RuntimeDefault"`                                                          |             |
| nextcloud.cronjob.enabled                                          | bool   | `true`                                                                      |             |
| nextcloud.cronjob.type                                             | string | `"cronjob"`                                                                 |             |
| nextcloud.externalDatabase.enabled                                 | bool   | `true`                                                                      |             |
| nextcloud.externalDatabase.existingSecret.enabled                  | bool   | `true`                                                                      |             |
| nextcloud.externalDatabase.existingSecret.passwordKey              | string | `"password"`                                                                |             |
| nextcloud.externalDatabase.existingSecret.secretName               | string | `"nextcloud-db"`                                                            |             |
| nextcloud.externalDatabase.existingSecret.usernameKey              | string | `"username"`                                                                |             |
| nextcloud.externalDatabase.host                                    | string | `"nextcloud-db-rw"`                                                         |             |
| nextcloud.externalDatabase.type                                    | string | `"postgresql"`                                                              |             |
| nextcloud.internalDatabase.enabled                                 | bool   | `false`                                                                     |             |
| nextcloud.nextcloud.existingSecret.enabled                         | bool   | `true`                                                                      |             |
| nextcloud.nextcloud.existingSecret.secretName                      | string | `"nextcloud-admin"`                                                         |             |
| nextcloud.nextcloud.podSecurityContext.seccompProfile.type         | string | `"RuntimeDefault"`                                                          |             |
| nextcloud.persistence.enabled                                      | bool   | `true`                                                                      |             |
| nextcloud.persistence.size                                         | string | `"20Gi"`                                                                    |             |
| nextcloud.resources.limits.cpu                                     | string | `"1"`                                                                       |             |
| nextcloud.resources.limits.memory                                  | string | `"1Gi"`                                                                     |             |
| nextcloud.resources.requests.cpu                                   | string | `"100m"`                                                                    |             |
| nextcloud.resources.requests.memory                                | string | `"256Mi"`                                                                   |             |
| nextcloud.startupProbe.enabled                                     | bool   | `true`                                                                      |             |
| nextcloud.startupProbe.failureThreshold                            | int    | `60`                                                                        |             |
