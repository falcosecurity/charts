{{/*
Expand the name of the chart.
*/}}
{{- define "event-generator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "event-generator.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "event-generator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "event-generator.labels" -}}
helm.sh/chart: {{ include "event-generator.chart" . }}
{{ include "event-generator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "event-generator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "event-generator.name" . | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/part-of: {{ include "event-generator.name" . | quote }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "event-generator.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "event-generator.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "grpc.unixSocketDir" -}}
{{- if and .Values.config.grpc.enabled .Values.config.grpc.bindAddress (hasPrefix "unix://" .Values.config.grpc.bindAddress) -}}
{{- .Values.config.grpc.bindAddress | trimPrefix "unix://" | dir -}}
{{- end -}}
{{- end -}}
