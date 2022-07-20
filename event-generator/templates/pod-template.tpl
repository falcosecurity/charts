{{- define "event-generator.podTemplate" -}}
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
        {{- toYaml .Values.securityContext | nindent 8 }}
      image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
      imagePullPolicy: {{ .Values.image.pullPolicy }}
      command: 
        - /bin/event-generator 
        - {{ .Values.config.command }}
        {{- if .Values.config.actions }}
        - {{ .Values.config.actions }}
        {{- end }}
        {{- if .Values.config.loop }}
        - --loop
        {{- end }}
        {{- if .Values.config.sleep }}
        - --sleep={{- .Values.config.sleep }}
        {{- end }}
        {{- if .Values.config.grpc.enabled }}
        - --grpc-unix-socket={{- .Values.config.grpc.bindAddress }}
        {{- end }}
      env:
      - name: FALCO_EVENT_GENERATOR_NAMESPACE
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace
      {{- if .Values.config.grpc.enabled }}
      volumeMounts:
      - mountPath: {{ include "grpc.unixSocketDir" . }} 
        name: unix-socket-dir
      {{- end }}
  {{- if .Values.config.grpc.enabled }}
  volumes:
  - hostPath:
      path: {{ include "grpc.unixSocketDir" . }} 
    name: unix-socket-dir       
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
  {{- if not .Values.config.loop }}
  restartPolicy: Never
  {{- end }}
{{- end -}}
