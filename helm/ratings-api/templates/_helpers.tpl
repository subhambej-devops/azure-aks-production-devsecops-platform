{{- define "ratings-api.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ratings-api.fullname" -}}
{{- printf "%s" (include "ratings-api.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ratings-api.labels" -}}
app.kubernetes.io/name: {{ include "ratings-api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

