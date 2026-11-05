# headscale

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.29.7](https://img.shields.io/badge/AppVersion-0.29.7-informational?style=flat-square)

Headscale open-source Tailscale-compatible control plane server

## Values

| Key                                | Type   | Default                                                                     | Description |
| ---------------------------------- | ------ | --------------------------------------------------------------------------- | ----------- |
| config.derp.server.enabled         | bool   | `false`                                                                     |             |
| config.derp.urls[0]                | string | `"https://controlplane.tailscale.com/derpmap/default"`                      |             |
| config.dns.baseDomain              | string | `"example.com"`                                                             |             |
| config.dns.magicDns                | bool   | `true`                                                                      |             |
| config.dns.nameservers.global[0]   | string | `"1.1.1.1"`                                                                 |             |
| config.dns.nameservers.global[1]   | string | `"1.0.0.1"`                                                                 |             |
| config.prefixes.v4                 | string | `"100.64.0.0/10"`                                                           |             |
| config.prefixes.v6                 | string | `"fd7a:115c:a1e0::/48"`                                                     |             |
| database.enabled                   | bool   | `false`                                                                     |             |
| database.image.digest              | string | `"sha256:dab846a58e8ca3c8872584ab2225ee93fb9e659a87c52e163fefae9275b46f51"` |             |
| database.image.repository          | string | `"ghcr.io/cloudnative-pg/postgresql"`                                       |             |
| database.image.tag                 | string | `"17.7"`                                                                    |             |
| database.resources.limits.cpu      | string | `"1"`                                                                       |             |
| database.resources.limits.memory   | string | `"1Gi"`                                                                     |             |
| database.resources.requests.cpu    | string | `"100m"`                                                                    |             |
| database.resources.requests.memory | string | `"256Mi"`                                                                   |             |
| database.storage.size              | string | `"8Gi"`                                                                     |             |
| httpRoute.enabled                  | bool   | `true`                                                                      |             |
| httpRoute.listener                 | string | `"http"`                                                                    |             |
| httpRoute.path                     | string | `"/"`                                                                       |             |
| httpRoute.port                     | int    | `8080`                                                                      |             |
| image.digest                       | string | `"sha256:11f81665e842809db9fe3006a38c56a66e968baa5abd4bac498e86445572b970"` |             |
| image.repository                   | string | `"headscale/headscale"`                                                     |             |
| image.tag                          | string | `"0.29.7"`                                                                  |             |
| networkPolicy.enabled              | bool   | `true`                                                                      |             |
| networkPolicy.port                 | int    | `8080`                                                                      |             |
| persistence.size                   | string | `"5Gi"`                                                                     |             |
| resources.limits.cpu               | string | `"500m"`                                                                    |             |
| resources.limits.memory            | string | `"512Mi"`                                                                   |             |
| resources.requests.cpu             | string | `"100m"`                                                                    |             |
| resources.requests.memory          | string | `"128Mi"`                                                                   |             |
