# kyverno-policies

![Version: 0.2.3](https://img.shields.io/badge/Version-0.2.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Kyverno Pod Security and custom policies

## Requirements

| Repository                        | Name             | Version |
| --------------------------------- | ---------------- | ------- |
| https://kyverno.github.io/kyverno | kyverno-policies | 3.9.2   |

## Values

| Key                                      | Type   | Default        | Description |
| ---------------------------------------- | ------ | -------------- | ----------- |
| customPolicies.validationFailureAction   | string | `"Audit"`      |             |
| kyverno-policies.podSecurityStandard     | string | `"restricted"` |             |
| kyverno-policies.validationFailureAction | string | `"Audit"`      |             |
