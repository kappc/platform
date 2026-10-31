{{- define "whoami.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "whoami.labels" -}}
app.kubernetes.io/name: {{ include "whoami.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "whoami.selectorLabels" -}}
app.kubernetes.io/name: {{ include "whoami.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
