{{/*
Expand the name of the chart.
*/}}
{{- define "falco.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "falco.fullname" -}}
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
{{- define "falco.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "falco.labels" -}}
helm.sh/chart: {{ include "falco.chart" . }}
{{ include "falco.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "falco.selectorLabels" -}}
app.kubernetes.io/name: {{ include "falco.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "falco.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "falco.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the proper Falco image name
*/}}
{{- define "falco.image" -}}
{{- with .Values.image.registry -}}
    {{- . }}/
{{- end -}}
{{- .Values.image.repository }}:
{{- .Values.image.tag | default .Chart.AppVersion -}}
{{- end -}}

{{/*
Return the proper Falco driver loader image name
*/}}
{{- define "falco.driverLoader.image" -}}
{{- with .Values.driver.loader.initContainer.image.registry -}}
    {{- . }}/
{{- end -}}
{{- .Values.driver.loader.initContainer.image.repository }}:
{{- .Values.driver.loader.initContainer.image.tag | default .Chart.AppVersion -}}
{{- end -}}

{{/*
Extract the unixSocket's directory path
*/}}
{{- define "falco.unixSocketDir" -}}
{{- if and .Values.falco.grpc.enabled .Values.falco.grpc.bind_address (hasPrefix "unix://" .Values.falco.grpc.bind_address) -}}
{{- .Values.falco.grpc.bind_address | trimPrefix "unix://" | dir -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for rbac.
*/}}
{{- define "rbac.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "rbac.authorization.k8s.io/v1" }}
{{- print "rbac.authorization.k8s.io/v1" -}}
{{- else -}}
{{- print "rbac.authorization.k8s.io/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
 Build http url for falcosidekick.
*/}}
{{- define "falcosidekick.url" -}}
{{- if not .Values.falco.http_output.url -}}
    {{- $falcoName := include "falco.fullname" . -}}
    {{- $listenPort := .Values.falcosidekick.listenport | default "2801" -}}
    {{- if .Values.falcosidekick.fullfqdn -}}
       {{- printf "http://%s-falcosidekick.%s.svc.cluster.local:%s" $falcoName .Release.Namespace $listenPort -}}
    {{- else -}}
        {{- printf "http://%s-falcosidekick:%s" $falcoName $listenPort -}}
    {{- end -}}
{{- else -}}
    {{- .Values.falco.http_output.url -}}
{{- end -}}
{{- end -}}


{{/*
Set appropriate falco configuration if falcosidekick has been configured.
*/}}
{{- define "falco.falcosidekickConfig" -}}
{{- if .Values.falcosidekick.enabled  -}}
    {{- $_ := set .Values.falco "json_output" true -}}
    {{- $_ := set .Values.falco "json_include_output_property" true -}}
    {{- $_ := set .Values.falco.http_output "enabled" true -}}
    {{- $_ := set .Values.falco.http_output "url" (include "falcosidekick.url" .) -}}
{{- end -}}
{{- end -}}

{{/*
Get port from .Values.falco.grpc.bind_addres.
*/}}
{{- define "grpc.port" -}}
{{- $error := "unable to extract listenPort from .Values.falco.grpc.bind_address. Make sure it is in the correct format" -}}
{{- if and .Values.falco.grpc.enabled .Values.falco.grpc.bind_address (not (hasPrefix "unix://" .Values.falco.grpc.bind_address)) -}}
    {{- $tokens := split ":" .Values.falco.grpc.bind_address -}}
    {{- if $tokens._1 -}}
        {{- $tokens._1 -}}
    {{- else -}}
        {{- fail $error -}}
    {{- end -}}
{{- else -}}
    {{- fail $error -}}
{{- end -}}
{{- end -}}

{{/*
Disable the syscall source if some conditions are met.
By default the syscall source is always enabled in falco. If no syscall source is enabled, falco
exits. Here we check that no producers for syscalls event has been configured, and if true
we just disable the sycall source.
*/}}
{{- define "falco.configSyscallSource" -}}
{{- $userspaceDisabled := true -}}
{{- $driverDisabled :=  (not .Values.driver.enabled) -}}
{{- if or (has "-u" .Values.extra.args) (has "--userspace" .Values.extra.args) -}}
{{- $userspaceDisabled = false -}}
{{- end -}}
{{- if and $driverDisabled $userspaceDisabled }}
- --disable-source
- syscall
{{- end -}}
{{- end -}}