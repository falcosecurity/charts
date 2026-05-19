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

{{/*
Returns "true" when command is suite-run or suite-test, "" otherwise.
*/}}
{{- define "event-generator.isSuiteCommand" -}}
{{- if or (eq .Values.config.command "suite-run") (eq .Values.config.command "suite-test") -}}
true
{{- end -}}
{{- end -}}

{{/*
Returns "true" when command is test or suite-test (i.e. an HTTP retriever is needed), "" otherwise.
For suite-test, returns "" when config.suite.skipOutcomeVerification is true, since outcome verification (and therefore
the HTTP retriever) is disabled.
*/}}
{{- define "event-generator.mustVerifyOutcome" -}}
{{- if or (eq .Values.config.command "test") (and (eq .Values.config.command "suite-test") (not .Values.config.suite.skipOutcomeVerification)) -}}
true
{{- end -}}
{{- end -}}

{{/*
Returns "true" when the workload should be a Deployment, "" otherwise. Suite commands always run once.
*/}}
{{- define "event-generator.useDeployment" -}}
{{- if and .Values.config.loop (not (include "event-generator.isSuiteCommand" .)) -}}
true
{{- end -}}
{{- end -}}

{{/*
Renders the argv to pass to the binary. Splits suite commands into two list items, and leaves non-suite commands as is.
*/}}
{{- define "event-generator.commandArgv" -}}
{{- if include "event-generator.isSuiteCommand" . -}}
- suite
- {{ .Values.config.command | trimPrefix "suite-" }}
{{- else -}}
- {{ .Values.config.command }}
{{- end -}}
{{- end -}}

{{/*
Directory where TLS material from config.http.tls.existingSecret is projected inside the pod.
*/}}
{{- define "event-generator.certMountDir" -}}/etc/falco/certs{{- end -}}

{{/*
File paths projected under certMountDir from config.http.tls.existingSecret. Passed to the event-generator via
--http-server-cert, --http-server-key and (mtls only) --http-client-ca.
*/}}
{{- define "event-generator.certFile" -}}{{ include "event-generator.certMountDir" . }}/server.crt{{- end -}}
{{- define "event-generator.keyFile" -}}{{ include "event-generator.certMountDir" . }}/server.key{{- end -}}
{{- define "event-generator.caRootFile" -}}{{ include "event-generator.certMountDir" . }}/ca.crt{{- end -}}

{{/*
Container securityContext. Defaults privileged=true unless the user explicitly sets `privileged` in
.Values.securityContext.
*/}}
{{- define "event-generator.containerSecurityContext" -}}
{{- $sc := deepCopy (.Values.securityContext | default dict) -}}
{{- if and (include "event-generator.isSuiteCommand" .) (not (hasKey $sc "privileged")) -}}
{{- $_ := set $sc "privileged" true -}}
{{- end -}}
{{- toYaml $sc -}}
{{- end -}}

{{/*
Fails template rendering if the configuration is inconsistent.
*/}}
{{- define "event-generator.validate" -}}
{{- $validCommands := list "run" "test" "suite-run" "suite-test" -}}
{{- if not (has .Values.config.command $validCommands) -}}
{{- fail (printf "config.command must be one of %v (got %q)" $validCommands .Values.config.command) -}}
{{- end -}}
{{- $validSecurityModes := list "insecure" "tls" "mtls" -}}
{{- if not (has .Values.config.http.securityMode $validSecurityModes) -}}
{{- fail (printf "config.http.securityMode must be one of %v (got %q)" $validSecurityModes .Values.config.http.securityMode) -}}
{{- end -}}
{{- if and (ne .Values.config.http.securityMode "insecure") (not .Values.config.http.tls.existingSecret) -}}
{{- fail (printf "config.http.tls.existingSecret must be set when config.http.securityMode is %q" .Values.config.http.securityMode) -}}
{{- end -}}
{{- if and (include "event-generator.isSuiteCommand" .) (empty .Values.config.suite.existingConfigMap) (empty .Values.config.suite.descriptions) -}}
{{- fail "config.suite.descriptions or config.suite.existingConfigMap must be set when config.command is suite-run or suite-test" -}}
{{- end -}}
{{- end -}}
