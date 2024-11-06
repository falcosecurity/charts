{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "falco-talon.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "falco-talon.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "falco-talon.ingress.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "networking.k8s.io/v1") (semverCompare ">= 1.19-0" .Capabilities.KubeVersion.Version) -}}
      {{- print "networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
    {{- print "networking.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "falco-talon.labels" -}}
helm.sh/chart: {{ include "falco-talon.chart" . }}
app.kubernetes.io/part-of: {{ include "falco-talon.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Name }}
{{ include "falco-talon.selectorLabels" . }}
{{- if .Values.image.tag }}
app.kubernetes.io/version: {{ .Values.image.tag }}
{{- else }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "falco-talon.selectorLabels" -}}
app.kubernetes.io/name: {{ include "falco-talon.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Return if ingress is stable.
*/}}
{{- define "falco-talon.ingress.isStable" -}}
  {{- eq (include "falco-talon.ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return if ingress supports pathType.
*/}}
{{- define "falco-talon.ingress.supportsPathType" -}}
  {{- or (eq (include "falco-talon.ingress.isStable" .) "true") (and (eq (include "falco-talon.ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18-0" .Capabilities.KubeVersion.Version)) -}}
{{- end -}}

{{/*
Validate if either serviceAccount create is set to true or serviceAccount name is passed
*/}}
{{- define "falco-talon.validateServiceAccount" -}}
  {{- if and (not .Values.rbac.serviceAccount.create) (not .Values.rbac.serviceAccount.name) -}}
  {{- fail ".Values.rbac.serviceAccount.create is set to false and .Values.rbac.serviceAccount.name is not provided or is provided as empty string." -}}
  {{- end -}}
{{- end -}}
