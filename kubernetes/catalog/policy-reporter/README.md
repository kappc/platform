# policy-reporter

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Policy Reporter dashboard with Kyverno integration

## Requirements

| Repository                                | Name            | Version |
| ----------------------------------------- | --------------- | ------- |
| https://kyverno.github.io/policy-reporter | policy-reporter | 3.11.2  |

## Values

| Key                                                      | Type   | Default                                        | Description |
| -------------------------------------------------------- | ------ | ---------------------------------------------- | ----------- |
| policy-reporter.plugin.kyverno.enabled                   | bool   | `true`                                         |             |
| policy-reporter.plugin.kyverno.resources.limits.cpu      | string | `"250m"`                                       |             |
| policy-reporter.plugin.kyverno.resources.limits.memory   | string | `"64Mi"`                                       |             |
| policy-reporter.plugin.kyverno.resources.requests.cpu    | string | `"25m"`                                        |             |
| policy-reporter.plugin.kyverno.resources.requests.memory | string | `"32Mi"`                                       |             |
| policy-reporter.resources.limits.cpu                     | string | `"250m"`                                       |             |
| policy-reporter.resources.limits.memory                  | string | `"128Mi"`                                      |             |
| policy-reporter.resources.requests.cpu                   | string | `"25m"`                                        |             |
| policy-reporter.resources.requests.memory                | string | `"64Mi"`                                       |             |
| policy-reporter.ui.clusters[0].host                      | string | `"http://policy-reporter:8080"`                |             |
| policy-reporter.ui.clusters[0].name                      | string | `"default"`                                    |             |
| policy-reporter.ui.clusters[0].plugins[0].host           | string | `"http://policy-reporter-kyverno-plugin:8080"` |             |
| policy-reporter.ui.clusters[0].plugins[0].name           | string | `"kyverno"`                                    |             |
| policy-reporter.ui.enabled                               | bool   | `true`                                         |             |
| policy-reporter.ui.resources.limits.cpu                  | string | `"250m"`                                       |             |
| policy-reporter.ui.resources.limits.memory               | string | `"64Mi"`                                       |             |
| policy-reporter.ui.resources.requests.cpu                | string | `"25m"`                                        |             |
| policy-reporter.ui.resources.requests.memory             | string | `"32Mi"`                                       |             |
