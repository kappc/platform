# outline

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Outline knowledge base

## Requirements

| Repository                                     | Name    | Version |
| ---------------------------------------------- | ------- | ------- |
| https://community-charts.github.io/helm-charts | outline | 0.9.5   |

## Values

| Key                                              | Type   | Default                                                                            | Description |
| ------------------------------------------------ | ------ | ---------------------------------------------------------------------------------- | ----------- |
| database.enabled                                 | bool   | `true`                                                                             |             |
| database.image.digest                            | string | `"sha256:dab846a58e8ca3c8872584ab2225ee93fb9e659a87c52e163fefae9275b46f51"`        |             |
| database.image.repository                        | string | `"ghcr.io/cloudnative-pg/postgresql"`                                              |             |
| database.image.tag                               | string | `"17.7"`                                                                           |             |
| database.resources.limits.cpu                    | string | `"1"`                                                                              |             |
| database.resources.limits.memory                 | string | `"1Gi"`                                                                            |             |
| database.resources.requests.cpu                  | string | `"100m"`                                                                           |             |
| database.resources.requests.memory               | string | `"256Mi"`                                                                          |             |
| database.storage.size                            | string | `"8Gi"`                                                                            |             |
| externalSecrets[0].data.oidc-client-secret       | string | `"oidc-client-secret"`                                                             |             |
| externalSecrets[0].data.secret-key               | string | `"secret-key"`                                                                     |             |
| externalSecrets[0].data.utils-secret             | string | `"utils-secret"`                                                                   |             |
| externalSecrets[0].name                          | string | `"outline-config"`                                                                 |             |
| externalSecrets[1].data.redis-password           | string | `"redis-password"`                                                                 |             |
| externalSecrets[1].name                          | string | `"outline-redis"`                                                                  |             |
| httpRoute.enabled                                | bool   | `true`                                                                             |             |
| httpRoute.listener                               | string | `"http"`                                                                           |             |
| httpRoute.path                                   | string | `"/"`                                                                              |             |
| httpRoute.port                                   | int    | `3000`                                                                             |             |
| networkPolicy.enabled                            | bool   | `true`                                                                             |             |
| networkPolicy.port                               | int    | `3000`                                                                             |             |
| outline.auth.oidc.clientId                       | string | `"outline"`                                                                        |             |
| outline.auth.oidc.displayName                    | string | `"Authentik"`                                                                      |             |
| outline.auth.oidc.enabled                        | bool   | `true`                                                                             |             |
| outline.auth.oidc.existingSecret.clientSecretKey | string | `"oidc-client-secret"`                                                             |             |
| outline.auth.oidc.existingSecret.name            | string | `"outline-config"`                                                                 |             |
| outline.auth.oidc.scopes[0]                      | string | `"openid"`                                                                         |             |
| outline.auth.oidc.scopes[1]                      | string | `"profile"`                                                                        |             |
| outline.auth.oidc.scopes[2]                      | string | `"email"`                                                                          |             |
| outline.auth.oidc.tokenUri                       | string | `"http://authentik-server.authentik.svc.cluster.local:80/application/o/token/"`    |             |
| outline.auth.oidc.userInfoUri                    | string | `"http://authentik-server.authentik.svc.cluster.local:80/application/o/userinfo/"` |             |
| outline.auth.oidc.usernameClaim                  | string | `"preferred_username"`                                                             |             |
| outline.externalPostgresql.database              | string | `"outline"`                                                                        |             |
| outline.externalPostgresql.existingSecret        | string | `"outline-db"`                                                                     |             |
| outline.externalPostgresql.host                  | string | `"outline-db-rw"`                                                                  |             |
| outline.externalPostgresql.passwordSecretKey     | string | `"password"`                                                                       |             |
| outline.externalPostgresql.username              | string | `"outline"`                                                                        |             |
| outline.fileStorage.local.persistence.enabled    | bool   | `true`                                                                             |             |
| outline.fileStorage.local.persistence.size       | string | `"8Gi"`                                                                            |             |
| outline.fileStorage.mode                         | string | `"local"`                                                                          |             |
| outline.ingress.enabled                          | bool   | `false`                                                                            |             |
| outline.podSecurityContext.seccompProfile.type   | string | `"RuntimeDefault"`                                                                 |             |
| outline.postgresql.enabled                       | bool   | `false`                                                                            |             |
| outline.redis.architecture                       | string | `"standalone"`                                                                     |             |
| outline.redis.auth.enabled                       | bool   | `true`                                                                             |             |
| outline.redis.auth.existingSecret                | string | `"outline-redis"`                                                                  |             |
| outline.redis.auth.existingSecretPasswordKey     | string | `"redis-password"`                                                                 |             |
| outline.redis.enabled                            | bool   | `true`                                                                             |             |
| outline.redis.image.digest                       | string | `"sha256:25bf63f3caf75af4628c0dfcf39859ad1ac8abe135be85e99699f9637b16dc28"`        |             |
| outline.redis.image.tag                          | string | `"8.2.1-debian-12-r0"`                                                             |             |
| outline.redis.master.persistence.enabled         | bool   | `false`                                                                            |             |
| outline.redis.master.resources.limits.cpu        | string | `"250m"`                                                                           |             |
| outline.redis.master.resources.limits.memory     | string | `"256Mi"`                                                                          |             |
| outline.redis.master.resources.requests.cpu      | string | `"50m"`                                                                            |             |
| outline.redis.master.resources.requests.memory   | string | `"64Mi"`                                                                           |             |
| outline.secretKeyExternalSecret.key              | string | `"secret-key"`                                                                     |             |
| outline.secretKeyExternalSecret.name             | string | `"outline-config"`                                                                 |             |
| outline.service.port                             | int    | `3000`                                                                             |             |
| outline.utilsSecretExternalSecret.key            | string | `"utils-secret"`                                                                   |             |
| outline.utilsSecretExternalSecret.name           | string | `"outline-config"`                                                                 |             |
| outline.web.forceHttps                           | bool   | `false`                                                                            |             |
