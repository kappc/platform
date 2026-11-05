# sonarqube

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

SonarQube code quality and security analysis

## Requirements

| Repository                                         | Name      | Version     |
| -------------------------------------------------- | --------- | ----------- |
| https://SonarSource.github.io/helm-chart-sonarqube | sonarqube | 2026.5.1003 |

## Values

| Key                                                  | Type   | Default                                                                                             | Description |
| ---------------------------------------------------- | ------ | --------------------------------------------------------------------------------------------------- | ----------- |
| database.enabled                                     | bool   | `true`                                                                                              |             |
| database.image.digest                                | string | `"sha256:dab846a58e8ca3c8872584ab2225ee93fb9e659a87c52e163fefae9275b46f51"`                         |             |
| database.image.repository                            | string | `"ghcr.io/cloudnative-pg/postgresql"`                                                               |             |
| database.image.tag                                   | string | `"17.7"`                                                                                            |             |
| database.resources.limits.cpu                        | string | `"1"`                                                                                               |             |
| database.resources.limits.memory                     | string | `"1Gi"`                                                                                             |             |
| database.resources.requests.cpu                      | string | `"100m"`                                                                                            |             |
| database.resources.requests.memory                   | string | `"256Mi"`                                                                                           |             |
| database.storage.size                                | string | `"8Gi"`                                                                                             |             |
| externalSecrets[0].data.monitoring-passcode          | string | `"monitoring-passcode"`                                                                             |             |
| externalSecrets[0].name                              | string | `"sonarqube-config"`                                                                                |             |
| externalSecrets[1].data.currentPassword              | string | `"admin-current-password"`                                                                          |             |
| externalSecrets[1].data.password                     | string | `"admin-password"`                                                                                  |             |
| externalSecrets[1].name                              | string | `"sonarqube-admin"`                                                                                 |             |
| httpRoute.enabled                                    | bool   | `true`                                                                                              |             |
| httpRoute.listener                                   | string | `"http"`                                                                                            |             |
| httpRoute.path                                       | string | `"/"`                                                                                               |             |
| httpRoute.port                                       | int    | `9000`                                                                                              |             |
| networkPolicy.enabled                                | bool   | `true`                                                                                              |             |
| networkPolicy.port                                   | int    | `9000`                                                                                              |             |
| sonarqube.annotations."reloader.stakater.com/auto"   | string | `"true"`                                                                                            |             |
| sonarqube.community.enabled                          | bool   | `true`                                                                                              |             |
| sonarqube.deploymentType                             | string | `"Deployment"`                                                                                      |             |
| sonarqube.fullnameOverride                           | string | `"sonarqube"`                                                                                       |             |
| sonarqube.global.azure.images.sonarqube.image        | string | `"sonarqube"`                                                                                       |             |
| sonarqube.global.azure.images.sonarqube.registry     | string | `"docker.io"`                                                                                       |             |
| sonarqube.global.azure.images.sonarqube.tag          | string | `"26.9.0.129388-community@sha256:c0f1160bccfa435db4168c2d7df69af3c3ea7bfeb87395613014048fb33a68c1"` |             |
| sonarqube.initFs.enabled                             | bool   | `false`                                                                                             |             |
| sonarqube.initSysctl.enabled                         | bool   | `false`                                                                                             |             |
| sonarqube.jdbcOverwrite.enabled                      | bool   | `true`                                                                                              |             |
| sonarqube.jdbcOverwrite.jdbcSecretName               | string | `"sonarqube-db"`                                                                                    |             |
| sonarqube.jdbcOverwrite.jdbcSecretPasswordKey        | string | `"password"`                                                                                        |             |
| sonarqube.jdbcOverwrite.jdbcUrl                      | string | `"jdbc:postgresql://sonarqube-db-rw:5432/sonarqube"`                                                |             |
| sonarqube.jdbcOverwrite.jdbcUsername                 | string | `"sonarqube"`                                                                                       |             |
| sonarqube.monitoringPasscodeSecretKey                | string | `"monitoring-passcode"`                                                                             |             |
| sonarqube.monitoringPasscodeSecretName               | string | `"sonarqube-config"`                                                                                |             |
| sonarqube.persistence.enabled                        | bool   | `true`                                                                                              |             |
| sonarqube.persistence.size                           | string | `"10Gi"`                                                                                            |             |
| sonarqube.resources.limits.cpu                       | string | `"2"`                                                                                               |             |
| sonarqube.resources.limits.ephemeral-storage         | string | `"8192M"`                                                                                           |             |
| sonarqube.resources.limits.memory                    | string | `"8192M"`                                                                                           |             |
| sonarqube.resources.requests.cpu                     | string | `"400m"`                                                                                            |             |
| sonarqube.resources.requests.ephemeral-storage       | string | `"1536M"`                                                                                           |             |
| sonarqube.resources.requests.memory                  | string | `"4096M"`                                                                                           |             |
| sonarqube.serviceAccount.create                      | bool   | `true`                                                                                              |             |
| sonarqube.setAdminPassword.passwordSecretName        | string | `"sonarqube-admin"`                                                                                 |             |
| sonarqube.setAdminPassword.resources.limits.cpu      | string | `"100m"`                                                                                            |             |
| sonarqube.setAdminPassword.resources.limits.memory   | string | `"128Mi"`                                                                                           |             |
| sonarqube.setAdminPassword.resources.requests.cpu    | string | `"10m"`                                                                                             |             |
| sonarqube.setAdminPassword.resources.requests.memory | string | `"32Mi"`                                                                                            |             |
| sonarqube.tests.enabled                              | bool   | `false`                                                                                             |             |
