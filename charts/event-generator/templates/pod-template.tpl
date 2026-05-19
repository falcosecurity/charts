{{- define "event-generator.podTemplate" -}}
{{- include "event-generator.validate" . -}}
{{- $isSuiteCommand := include "event-generator.isSuiteCommand" . -}}
{{- $mustVerifyOutcome := include "event-generator.mustVerifyOutcome" . -}}
{{- $http := .Values.config.http -}}
{{- $suite := .Values.config.suite -}}
{{- $descriptionsConfigMap := default (printf "%s-descriptions" (include "event-generator.fullname" .)) $suite.existingConfigMap -}}
{{- $mustVerifyOutcomeSecurely := and $mustVerifyOutcome (ne $http.securityMode "insecure") -}}
metadata:
  {{- with .Values.podAnnotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "event-generator.selectorLabels" . | nindent 4 }}
spec:
  {{- with .Values.imagePullSecrets }}
  imagePullSecrets:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  serviceAccountName: {{ include "event-generator.fullname" . }}
  securityContext:
    {{- toYaml .Values.podSecurityContext | nindent 4 }}
  containers:
    - name: {{ .Chart.Name }}
      securityContext:
        {{- include "event-generator.containerSecurityContext" . | nindent 8 }}
      image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
      imagePullPolicy: {{ .Values.image.pullPolicy }}
      command:
        - /bin/event-generator
        {{- include "event-generator.commandArgv" . | nindent 8 }}
        {{- if not $isSuiteCommand }}
        - --all
        {{- if .Values.config.actions }}
        - {{ .Values.config.actions }}
        {{- end }}
        {{- if .Values.config.loop }}
        - --loop
        {{- end }}
        {{- if .Values.config.sleep }}
        - --sleep={{ .Values.config.sleep }}
        {{- end }}
        {{- end }}
        {{- if $isSuiteCommand }}
        - --description-dir={{ $suite.descriptionDir }}
        - --timeout={{ $suite.timeout }}
        {{- if eq .Values.config.command "suite-test" }}
        - --report-format={{ $suite.reportFormat }}
        {{- if $suite.skipOutcomeVerification }}
        - --skip-outcome-verification
        {{- end }}
        {{- end }}
        {{- end }}
        {{- if $mustVerifyOutcome }}
        - --http-server-address={{ $http.address }}
        - --http-server-security-mode={{ $http.securityMode }}
        {{- if $mustVerifyOutcomeSecurely }}
        - --http-server-cert={{ include "event-generator.certFile" . }}
        - --http-server-key={{ include "event-generator.keyFile" . }}
        {{- if eq $http.securityMode "mtls" }}
        - --http-client-ca={{ include "event-generator.caRootFile" . }}
        {{- end }}
        {{- end }}
        {{- end }}
      {{- if $mustVerifyOutcome }}
      ports:
        - name: http
          containerPort: {{ $http.address | splitList ":" | last | int }}
          protocol: TCP
      {{- end }}
      env:
        - name: FALCO_EVENT_GENERATOR_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
      {{- if or $isSuiteCommand $mustVerifyOutcomeSecurely }}
      volumeMounts:
        {{- if $isSuiteCommand }}
        - name: descriptions
          mountPath: {{ $suite.descriptionDir }}
          readOnly: true
        {{- end }}
        {{- if $mustVerifyOutcomeSecurely }}
        - name: certs
          mountPath: {{ include "event-generator.certMountDir" . }}
          readOnly: true
        {{- end }}
      {{- end }}
  {{- if or $isSuiteCommand $mustVerifyOutcomeSecurely }}
  volumes:
    {{- if $isSuiteCommand }}
    - name: descriptions
      configMap:
        name: {{ $descriptionsConfigMap }}
    {{- end }}
    {{- if $mustVerifyOutcomeSecurely }}
    - name: certs
      secret:
        secretName: {{ $http.tls.existingSecret }}
        items:
          - key: {{ $http.tls.secretKeys.cert }}
            path: {{ include "event-generator.certFile" . | base }}
          - key: {{ $http.tls.secretKeys.key }}
            path: {{ include "event-generator.keyFile" . | base }}
          {{- if eq $http.securityMode "mtls" }}
          - key: {{ $http.tls.secretKeys.caRoot }}
            path: {{ include "event-generator.caRootFile" . | base }}
          {{- end }}
    {{- end }}
  {{- end }}
  {{- with .Values.nodeSelector }}
  nodeSelector:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.affinity }}
  affinity:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.tolerations }}
  tolerations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if not (include "event-generator.useDeployment" .) }}
  restartPolicy: Never
  {{- end }}
{{- end -}}
