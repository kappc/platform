{{- define "mail-archiver.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mail-archiver.labels" -}}
app.kubernetes.io/name: {{ include "mail-archiver.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "mail-archiver.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mail-archiver.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
