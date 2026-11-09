{{/*
Expand the name of the chart.
*/}}
{{- define "falco-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Compose the operator image, preserving custom repositories and digest precedence.
*/}}
{{- define "falco-operator.image" -}}
{{- $repository := .Values.image.repository -}}
{{- if and .Values.imageRegistry (eq $repository "falcosecurity/falco-operator") -}}
{{- $repository = printf "%s/%s" .Values.imageRegistry $repository -}}
{{- end -}}
{{- if .Values.image.digest -}}
{{ $repository }}@{{ .Values.image.digest }}
{{- else -}}
{{ $repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}
{{- end -}}
{{- end }}

{{/*
Keep the DNS default when upgrades reuse values from a chart without clusterDomain.
An explicitly empty value is still invalid.
*/}}
{{- define "falco-operator.clusterDomain" -}}
{{- if hasKey .Values "clusterDomain" -}}
{{- required "clusterDomain must not be empty" .Values.clusterDomain -}}
{{- else -}}
cluster.local
{{- end -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "falco-operator.fullname" -}}
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
{{- define "falco-operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "falco-operator.labels" -}}
helm.sh/chart: {{ include "falco-operator.chart" . }}
{{ include "falco-operator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "falco-operator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "falco-operator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "falco-operator.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "falco-operator.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the ClusterIssuer used to sign mTLS certificates: mtls.issuerName if set, else the one
this chart creates itself (mtls.createIssuer) named after the release.
*/}}
{{- define "falco-operator.mtlsIssuerName" -}}
{{- .Values.mtls.issuerName | default (printf "%s-artifact-ca-issuer" (include "falco-operator.fullname" .)) }}
{{- end }}

{{/*
Name of the ConfigMap (synced by trust-manager into every trust-labeled namespace) that both
the operator's own Deployment and every Falco instance's sidecar read to verify their peer's
certificate through a CA rotation. mtls.caBundleConfigMapName if set (needed when
mtls.createIssuer is false, since this chart isn't the one creating the Bundle, so it can't assume
its own naming convention), else the name of the Bundle this chart creates itself.
*/}}
{{- define "falco-operator.mtlsCABundleConfigMapName" -}}
{{- .Values.mtls.caBundleConfigMapName | default (printf "%s-artifact-ca-bundle" (include "falco-operator.fullname" .)) }}
{{- end }}
