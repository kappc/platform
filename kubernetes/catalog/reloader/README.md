# reloader

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.4.23](https://img.shields.io/badge/AppVersion-v1.4.23-informational?style=flat-square)

Stakater Reloader for restarting workloads when configuration changes

## Requirements

| Repository                                 | Name     | Version |
| ------------------------------------------ | -------- | ------- |
| https://stakater.github.io/stakater-charts | reloader | 2.2.19  |

## Values

| Key                                                                            | Type   | Default   | Description |
| ------------------------------------------------------------------------------ | ------ | --------- | ----------- |
| reloader.reloader.deployment.containerSecurityContext.allowPrivilegeEscalation | bool   | `false`   |             |
| reloader.reloader.deployment.containerSecurityContext.capabilities.drop[0]     | string | `"ALL"`   |             |
| reloader.reloader.deployment.containerSecurityContext.readOnlyRootFilesystem   | bool   | `true`    |             |
| reloader.reloader.deployment.resources.limits.cpu                              | string | `"250m"`  |             |
| reloader.reloader.deployment.resources.limits.memory                           | string | `"256Mi"` |             |
| reloader.reloader.deployment.resources.requests.cpu                            | string | `"50m"`   |             |
| reloader.reloader.deployment.resources.requests.memory                         | string | `"64Mi"`  |             |
| reloader.reloader.watchGlobally                                                | bool   | `false`   |             |
