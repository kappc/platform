# external-secrets

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

External Secrets Operator for synchronizing external secrets

## Requirements

| Repository                         | Name             | Version |
| ---------------------------------- | ---------------- | ------- |
| https://charts.external-secrets.io | external-secrets | 2.14.0  |

## Values

| Key                                                       | Type   | Default   | Description |
| --------------------------------------------------------- | ------ | --------- | ----------- |
| external-secrets.certController.resources.limits.cpu      | string | `"250m"`  |             |
| external-secrets.certController.resources.limits.memory   | string | `"256Mi"` |             |
| external-secrets.certController.resources.requests.cpu    | string | `"50m"`   |             |
| external-secrets.certController.resources.requests.memory | string | `"64Mi"`  |             |
| external-secrets.resources.limits.cpu                     | string | `"500m"`  |             |
| external-secrets.resources.limits.memory                  | string | `"512Mi"` |             |
| external-secrets.resources.requests.cpu                   | string | `"100m"`  |             |
| external-secrets.resources.requests.memory                | string | `"128Mi"` |             |
| external-secrets.webhook.resources.limits.cpu             | string | `"250m"`  |             |
| external-secrets.webhook.resources.limits.memory          | string | `"256Mi"` |             |
| external-secrets.webhook.resources.requests.cpu           | string | `"50m"`   |             |
| external-secrets.webhook.resources.requests.memory        | string | `"64Mi"`  |             |
