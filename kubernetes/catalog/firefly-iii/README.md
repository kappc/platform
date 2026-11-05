# firefly-iii

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Firefly III personal finance manager

## Requirements

| Repository                               | Name        | Version |
| ---------------------------------------- | ----------- | ------- |
| https://firefly-iii.github.io/kubernetes | firefly-iii | 1.10.2  |

## Values

| Key                                                          | Type   | Default                                                                                   | Description |
| ------------------------------------------------------------ | ------ | ----------------------------------------------------------------------------------------- | ----------- |
| database.enabled                                             | bool   | `true`                                                                                    |             |
| database.image.digest                                        | string | `"sha256:dab846a58e8ca3c8872584ab2225ee93fb9e659a87c52e163fefae9275b46f51"`               |             |
| database.image.repository                                    | string | `"ghcr.io/cloudnative-pg/postgresql"`                                                     |             |
| database.image.tag                                           | string | `"17.7"`                                                                                  |             |
| database.resources.limits.cpu                                | string | `"1"`                                                                                     |             |
| database.resources.limits.memory                             | string | `"1Gi"`                                                                                   |             |
| database.resources.requests.cpu                              | string | `"100m"`                                                                                  |             |
| database.resources.requests.memory                           | string | `"256Mi"`                                                                                 |             |
| database.storage.size                                        | string | `"8Gi"`                                                                                   |             |
| externalSecrets[0].data.APP_KEY                              | string | `"app-key"`                                                                               |             |
| externalSecrets[0].data.DB_PASSWORD                          | string | `"db-password"`                                                                           |             |
| externalSecrets[0].data.STATIC_CRON_TOKEN                    | string | `"cron-token"`                                                                            |             |
| externalSecrets[0].name                                      | string | `"firefly-iii-config"`                                                                    |             |
| firefly-iii.config.env.DB_CONNECTION                         | string | `"pgsql"`                                                                                 |             |
| firefly-iii.config.env.DB_DATABASE                           | string | `"firefly-iii"`                                                                           |             |
| firefly-iii.config.env.DB_HOST                               | string | `"firefly-iii-db-rw"`                                                                     |             |
| firefly-iii.config.env.DB_PORT                               | string | `"5432"`                                                                                  |             |
| firefly-iii.config.env.DB_USERNAME                           | string | `"firefly-iii"`                                                                           |             |
| firefly-iii.config.existingSecret                            | string | `"firefly-iii-config"`                                                                    |             |
| firefly-iii.cronjob.auth.existingSecret                      | string | `"firefly-iii-config"`                                                                    |             |
| firefly-iii.cronjob.auth.secretKey                           | string | `"STATIC_CRON_TOKEN"`                                                                     |             |
| firefly-iii.cronjob.enabled                                  | bool   | `true`                                                                                    |             |
| firefly-iii.cronjob.image.repository                         | string | `"curlimages/curl"`                                                                       |             |
| firefly-iii.cronjob.image.tag                                | string | `"8.12.0@sha256:3dfa70a646c5d03ddf0e7c0ff518a5661e95b8bcbc82079f0fb7453a96eaae35"`        |             |
| firefly-iii.cronjob.podSecurityContext.seccompProfile.type   | string | `"RuntimeDefault"`                                                                        |             |
| firefly-iii.cronjob.resources.limits.cpu                     | string | `"100m"`                                                                                  |             |
| firefly-iii.cronjob.resources.limits.memory                  | string | `"64Mi"`                                                                                  |             |
| firefly-iii.cronjob.resources.requests.cpu                   | string | `"10m"`                                                                                   |             |
| firefly-iii.cronjob.resources.requests.memory                | string | `"16Mi"`                                                                                  |             |
| firefly-iii.cronjob.securityContext.allowPrivilegeEscalation | bool   | `false`                                                                                   |             |
| firefly-iii.cronjob.securityContext.capabilities.drop[0]     | string | `"ALL"`                                                                                   |             |
| firefly-iii.cronjob.securityContext.readOnlyRootFilesystem   | bool   | `true`                                                                                    |             |
| firefly-iii.cronjob.securityContext.runAsGroup               | int    | `101`                                                                                     |             |
| firefly-iii.cronjob.securityContext.runAsNonRoot             | bool   | `true`                                                                                    |             |
| firefly-iii.cronjob.securityContext.runAsUser                | int    | `100`                                                                                     |             |
| firefly-iii.image.repository                                 | string | `"fireflyiii/core"`                                                                       |             |
| firefly-iii.image.tag                                        | string | `"version-6.7.9@sha256:d51ab6a3a7b91a5c892441578e0da7f2935f84f36bd1151fc3833acc6e060871"` |             |
| firefly-iii.persistence.storage                              | string | `"2Gi"`                                                                                   |             |
| firefly-iii.podAnnotations."reloader.stakater.com/auto"      | string | `"true"`                                                                                  |             |
| firefly-iii.podSecurityContext.fsGroup                       | int    | `33`                                                                                      |             |
| firefly-iii.podSecurityContext.seccompProfile.type           | string | `"RuntimeDefault"`                                                                        |             |
| firefly-iii.resources.limits.cpu                             | string | `"1"`                                                                                     |             |
| firefly-iii.resources.limits.memory                          | string | `"512Mi"`                                                                                 |             |
| firefly-iii.resources.requests.cpu                           | string | `"100m"`                                                                                  |             |
| firefly-iii.resources.requests.memory                        | string | `"256Mi"`                                                                                 |             |
| firefly-iii.securityContext.allowPrivilegeEscalation         | bool   | `false`                                                                                   |             |
| firefly-iii.securityContext.capabilities.drop[0]             | string | `"ALL"`                                                                                   |             |
| firefly-iii.securityContext.runAsGroup                       | int    | `33`                                                                                      |             |
| firefly-iii.securityContext.runAsNonRoot                     | bool   | `true`                                                                                    |             |
| firefly-iii.securityContext.runAsUser                        | int    | `33`                                                                                      |             |
| httpRoute.enabled                                            | bool   | `true`                                                                                    |             |
| httpRoute.listener                                           | string | `"http"`                                                                                  |             |
| httpRoute.path                                               | string | `"/"`                                                                                     |             |
| httpRoute.port                                               | int    | `80`                                                                                      |             |
| networkPolicy.enabled                                        | bool   | `true`                                                                                    |             |
| networkPolicy.port                                           | int    | `8080`                                                                                    |             |
