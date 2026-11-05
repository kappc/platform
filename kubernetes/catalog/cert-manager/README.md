# cert-manager

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

cert-manager certificate management

## Requirements

| Repository                    | Name         | Version |
| ----------------------------- | ------------ | ------- |
| oci://quay.io/jetstack/charts | cert-manager | v1.21.3 |

## Values

| Key                                                    | Type   | Default   | Description |
| ------------------------------------------------------ | ------ | --------- | ----------- |
| cert-manager.cainjector.resources.limits.cpu           | string | `"250m"`  |             |
| cert-manager.cainjector.resources.limits.memory        | string | `"256Mi"` |             |
| cert-manager.cainjector.resources.requests.cpu         | string | `"50m"`   |             |
| cert-manager.cainjector.resources.requests.memory      | string | `"64Mi"`  |             |
| cert-manager.crds.enabled                              | bool   | `true`    |             |
| cert-manager.resources.limits.cpu                      | string | `"500m"`  |             |
| cert-manager.resources.limits.memory                   | string | `"512Mi"` |             |
| cert-manager.resources.requests.cpu                    | string | `"100m"`  |             |
| cert-manager.resources.requests.memory                 | string | `"128Mi"` |             |
| cert-manager.startupapicheck.resources.limits.cpu      | string | `"100m"`  |             |
| cert-manager.startupapicheck.resources.limits.memory   | string | `"128Mi"` |             |
| cert-manager.startupapicheck.resources.requests.cpu    | string | `"25m"`   |             |
| cert-manager.startupapicheck.resources.requests.memory | string | `"32Mi"`  |             |
| cert-manager.webhook.resources.limits.cpu              | string | `"250m"`  |             |
| cert-manager.webhook.resources.limits.memory           | string | `"256Mi"` |             |
| cert-manager.webhook.resources.requests.cpu            | string | `"50m"`   |             |
| cert-manager.webhook.resources.requests.memory         | string | `"64Mi"`  |             |
