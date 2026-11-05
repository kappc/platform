# gitea

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Gitea self-hosted Git service

## Requirements

| Repository                   | Name  | Version |
| ---------------------------- | ----- | ------- |
| https://dl.gitea.com/charts/ | gitea | 12.7.0  |

## Values

| Key                                                                 | Type   | Default                                                                                                            | Description |
| ------------------------------------------------------------------- | ------ | ------------------------------------------------------------------------------------------------------------------ | ----------- |
| database.enabled                                                    | bool   | `true`                                                                                                             |             |
| database.image.digest                                               | string | `"sha256:dab846a58e8ca3c8872584ab2225ee93fb9e659a87c52e163fefae9275b46f51"`                                        |             |
| database.image.repository                                           | string | `"ghcr.io/cloudnative-pg/postgresql"`                                                                              |             |
| database.image.tag                                                  | string | `"17.7"`                                                                                                           |             |
| database.resources.limits.cpu                                       | string | `"1"`                                                                                                              |             |
| database.resources.limits.memory                                    | string | `"1Gi"`                                                                                                            |             |
| database.resources.requests.cpu                                     | string | `"100m"`                                                                                                           |             |
| database.resources.requests.memory                                  | string | `"256Mi"`                                                                                                          |             |
| database.storage.size                                               | string | `"8Gi"`                                                                                                            |             |
| externalSecrets[0].data.password                                    | string | `"admin-password"`                                                                                                 |             |
| externalSecrets[0].data.username                                    | string | `"admin-username"`                                                                                                 |             |
| externalSecrets[0].name                                             | string | `"gitea-admin"`                                                                                                    |             |
| gitea.containerSecurityContext.allowPrivilegeEscalation             | bool   | `false`                                                                                                            |             |
| gitea.containerSecurityContext.capabilities.drop[0]                 | string | `"ALL"`                                                                                                            |             |
| gitea.containerSecurityContext.readOnlyRootFilesystem               | bool   | `true`                                                                                                             |             |
| gitea.containerSecurityContext.runAsGroup                           | int    | `1000`                                                                                                             |             |
| gitea.containerSecurityContext.runAsNonRoot                         | bool   | `true`                                                                                                             |             |
| gitea.containerSecurityContext.runAsUser                            | int    | `1000`                                                                                                             |             |
| gitea.deployment.annotations."reloader.stakater.com/auto"           | string | `"true"`                                                                                                           |             |
| gitea.gitea.additionalConfigFromEnvs[0].name                        | string | `"GITEA__DATABASE__PASSWD"`                                                                                        |             |
| gitea.gitea.additionalConfigFromEnvs[0].valueFrom.secretKeyRef.key  | string | `"password"`                                                                                                       |             |
| gitea.gitea.additionalConfigFromEnvs[0].valueFrom.secretKeyRef.name | string | `"gitea-db"`                                                                                                       |             |
| gitea.gitea.admin.existingSecret                                    | string | `"gitea-admin"`                                                                                                    |             |
| gitea.gitea.config.database.DB_TYPE                                 | string | `"postgres"`                                                                                                       |             |
| gitea.gitea.config.database.HOST                                    | string | `"gitea-db-rw:5432"`                                                                                               |             |
| gitea.gitea.config.database.NAME                                    | string | `"gitea"`                                                                                                          |             |
| gitea.gitea.config.database.USER                                    | string | `"gitea"`                                                                                                          |             |
| gitea.gitea.config.service.DISABLE_REGISTRATION                     | bool   | `true`                                                                                                             |             |
| gitea.image.fullOverride                                            | string | `"docker.gitea.com/gitea:1.27.0-rootless@sha256:414ba5b2b1163480e9ed4213a989cd798579cfa88582a2359303273009b2b852"` |             |
| gitea.initContainers.resources.limits.cpu                           | string | `"500m"`                                                                                                           |             |
| gitea.initContainers.resources.limits.memory                        | string | `"256Mi"`                                                                                                          |             |
| gitea.initContainers.resources.requests.cpu                         | string | `"100m"`                                                                                                           |             |
| gitea.initContainers.resources.requests.memory                      | string | `"128Mi"`                                                                                                          |             |
| gitea.podSecurityContext.fsGroup                                    | int    | `1000`                                                                                                             |             |
| gitea.podSecurityContext.seccompProfile.type                        | string | `"RuntimeDefault"`                                                                                                 |             |
| gitea.postgresql-ha.enabled                                         | bool   | `false`                                                                                                            |             |
| gitea.resources.limits.cpu                                          | string | `"1"`                                                                                                              |             |
| gitea.resources.limits.memory                                       | string | `"1Gi"`                                                                                                            |             |
| gitea.resources.requests.cpu                                        | string | `"100m"`                                                                                                           |             |
| gitea.resources.requests.memory                                     | string | `"256Mi"`                                                                                                          |             |
| gitea.serviceAccount.create                                         | bool   | `true`                                                                                                             |             |
| gitea.test.enabled                                                  | bool   | `false`                                                                                                            |             |
| gitea.valkey-cluster.enabled                                        | bool   | `false`                                                                                                            |             |
| httpRoute.enabled                                                   | bool   | `true`                                                                                                             |             |
| httpRoute.listener                                                  | string | `"http"`                                                                                                           |             |
| httpRoute.path                                                      | string | `"/"`                                                                                                              |             |
| httpRoute.port                                                      | int    | `3000`                                                                                                             |             |
| httpRoute.service                                                   | string | `"gitea-http"`                                                                                                     |             |
| networkPolicy.allow[0]                                              | string | `"gitea-runner"`                                                                                                   |             |
| networkPolicy.enabled                                               | bool   | `true`                                                                                                             |             |
| networkPolicy.port                                                  | int    | `3000`                                                                                                             |             |
