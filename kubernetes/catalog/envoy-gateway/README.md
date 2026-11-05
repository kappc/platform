# envoy-gateway

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Envoy Gateway controller and Gateway API resources

## Requirements

| Repository                 | Name         | Version |
| -------------------------- | ------------ | ------- |
| oci://docker.io/envoyproxy | gateway-helm | v1.9.3  |

## Values

| Key                                                            | Type   | Default                          | Description                                                                                                                                                                |
| -------------------------------------------------------------- | ------ | -------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| envoyProxy.name                                                | string | `"envoy-proxy"`                  |                                                                                                                                                                            |
| envoyProxy.service.annotations                                 | object | `{}`                             |                                                                                                                                                                            |
| envoyProxy.service.externalTrafficPolicy                       | string | `"Cluster"`                      |                                                                                                                                                                            |
| envoyProxy.service.port                                        | int    | `80`                             |                                                                                                                                                                            |
| envoyProxy.service.type                                        | string | `"LoadBalancer"`                 |                                                                                                                                                                            |
| gateway-helm.crds.enabled                                      | bool   | `true`                           |                                                                                                                                                                            |
| gateway-helm.deployment.envoyGateway.resources.limits.cpu      | string | `"500m"`                         |                                                                                                                                                                            |
| gateway-helm.deployment.envoyGateway.resources.limits.memory   | string | `"512Mi"`                        |                                                                                                                                                                            |
| gateway-helm.deployment.envoyGateway.resources.requests.cpu    | string | `"100m"`                         |                                                                                                                                                                            |
| gateway-helm.deployment.envoyGateway.resources.requests.memory | string | `"256Mi"`                        |                                                                                                                                                                            |
| gateway-helm.deployment.replicas                               | int    | `1`                              |                                                                                                                                                                            |
| gateway.allowedRoutes                                          | object | `{"namespaces":{"from":"Same"}}` | Which namespaces may attach routes to all listeners; `Same` admits the gateway namespace only, `All` every namespace, and `Selector` with a `selector` specific namespaces |
| gateway.listener.name                                          | string | `"http"`                         |                                                                                                                                                                            |
| gateway.listener.port                                          | int    | `80`                             |                                                                                                                                                                            |
| gateway.name                                                   | string | `"gateway"`                      |                                                                                                                                                                            |
| gateway.tls.certificate.dnsNames                               | list   | `[]`                             | DNS names of the certificate                                                                                                                                               |
| gateway.tls.certificate.issuerRef                              | object | `{}`                             | Existing cert-manager issuer for the certificate; when empty, a private CA is created                                                                                      |
| gateway.tls.enabled                                            | bool   | `false`                          | Add an HTTPS listener that terminates TLS with the certificate in `secretName` (requires cert-manager)                                                                     |
| gateway.tls.listener.hostname                                  | string | `""`                             | Hostname served by the listener                                                                                                                                            |
| gateway.tls.listener.name                                      | string | `"https"`                        |                                                                                                                                                                            |
| gateway.tls.listener.port                                      | int    | `443`                            |                                                                                                                                                                            |
| gateway.tls.secretName                                         | string | `"gateway-tls"`                  | Name of the `Secret` that holds the certificate                                                                                                                            |
| gatewayClass.name                                              | string | `"envoy-gateway"`                |                                                                                                                                                                            |
