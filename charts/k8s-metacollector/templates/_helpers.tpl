{{/*
Expand the name of the chart.
*/}}
{{- define "k8s-metacollector.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "k8s-metacollector.fullname" -}}
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
{{- define "k8s-metacollector.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "k8s-metacollector.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride -}}
{{- end }}

{{/*
Common labels
*/}}
{{- define "k8s-metacollector.labels" -}}
helm.sh/chart: {{ include "k8s-metacollector.chart" . }}
{{ include "k8s-metacollector.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: "metadata-collector"
{{- end }}

{{/*
Selector labels
*/}}
{{- define "k8s-metacollector.selectorLabels" -}}
app.kubernetes.io/name: {{ include "k8s-metacollector.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Return the proper k8s-metacollector image name
*/}}
{{- define "k8s-metacollector.image" -}}
"
{{- with .Values.image.registry -}}
    {{- . }}/
{{- end -}}
{{- .Values.image.repository }}:
{{- .Values.image.tag | default .Chart.AppVersion -}}
"
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "k8s-metacollector.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "k8s-metacollector.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate the ports for the service
*/}}
{{- define "k8s-metacollector.servicePorts" -}}
{{- if .Values.service.create }}
{{- with .Values.service.ports }}
{{- range $key, $value := . }}
- name: {{ $key }}
{{- range $key1, $value1 := $value }}
  {{ $key1}}: {{ $value1 }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Generate the ports for the container
*/}}
{{- define "k8s-metacollector.containerPorts" -}}
{{- if .Values.service.create }}
{{- with .Values.service.ports }}
{{- range $key, $value := . }}
- name: "{{ $key }}" 
{{- range $key1, $value1 := $value }}
  {{- if ne $key1 "targetPort" }}
  {{- if eq $key1 "port" }}
  containerPort: {{ $value1 }}
  {{- else }}
  {{ $key1}}: {{ $value1 }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
