# cloudnative-pg

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

CloudNativePG operator for PostgreSQL clusters

## Requirements

| Repository                              | Name           | Version |
| --------------------------------------- | -------------- | ------- |
| https://cloudnative-pg.github.io/charts | cloudnative-pg | 0.29.1  |

## Values

| Key                                      | Type   | Default   | Description |
| ---------------------------------------- | ------ | --------- | ----------- |
| cloudnative-pg.resources.limits.cpu      | string | `"500m"`  |             |
| cloudnative-pg.resources.limits.memory   | string | `"512Mi"` |             |
| cloudnative-pg.resources.requests.cpu    | string | `"100m"`  |             |
| cloudnative-pg.resources.requests.memory | string | `"128Mi"` |             |
