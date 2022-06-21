{{- define "falco.podTemplate" -}}
metadata:
  name: {{ include "falco.fullname" . }}
  labels:
    {{- include "falco.selectorLabels" . | nindent 4 }}
    {{- with .Values.podLabels }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
  annotations:
    checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
    checksum/rules: {{ include (print $.Template.BasePath "/rules-configmap.yaml") . | sha256sum }}
    {{- if and .Values.certs (not .Values.certs.existingSecret) }}
    checksum/certs: {{ include (print $.Template.BasePath "/certs-secret.yaml") . | sha256sum }}
    {{- end }}
    {{- with .Values.podAnnotations }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  serviceAccountName: {{ include "falco.serviceAccountName" . }}
  {{- with .Values.podSecurityContext }}
  securityContext:
    {{- toYaml . | nindent 4}}
  {{- end }}
  {{- if .Values.driver.enabled -}}
  {{- if and .Values.driver.ebpf.enabled .Values.driver.ebpf.hostNetwork }}
  hostNetwork: true
  dnsPolicy: ClusterFirstWithHostNet
  {{- end }}
  {{- end -}}
  {{- if .Values.priorityClassName }}
  priorityClassName: {{ .Values.priorityClassName }}
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
  {{- with .Values.imagePullSecrets }}
  imagePullSecrets: 
    {{- toYaml . | nindent 4 }}
  {{- end }}
  containers:
    - name: {{ .Chart.Name }}
      image: {{ include "falco.image" . }}
      imagePullPolicy: {{ .Values.image.pullPolicy }}
      resources:
        {{- toYaml .Values.resources | nindent 8 }}
      securityContext:
        {{- if not .Values.leastPrivileged.enabled }}
        privileged: true
        {{- if .Values.securityContext }}
          {{- omit .Values.securityContext "privileged" | toYaml | nindent 8 }}
        {{- end }}
        {{- else }}
        capabilities:
          add:
          - BPF
          - SYS_RESOURCE
          - PERFMON
        {{- if .Values.securityContext }}
          {{- omit .Values.securityContext "privileged" "capabilities" | toYaml | nindent 8 }}
        {{- end }}
        {{- end }}
      args:
        - /usr/bin/falco
        {{- if and .Values.containerd .Values.containerd.enabled }}
        - --cri
        - /run/containerd/containerd.sock
        {{- end }}
        {{- if and .Values.crio .Values.crio.enabled }}
        - --cri
        - /run/crio/crio.sock
        {{- end }}
        {{- if .Values.kubernetesSupport.enabled }}
        - -K
        - {{ .Values.kubernetesSupport.apiAuth }}
        - -k
        - {{ .Values.kubernetesSupport.apiUrl }}
        {{- if .Values.kubernetesSupport.enableNodeFilter }}
        - --k8s-node
        - "$(FALCO_K8S_NODE_NAME)"
        {{- end }}
        {{- end }}
        - -pk
    {{- with .Values.extra.args }}
      {{- toYaml . | nindent 8 }}
    {{- end }}
      env:
        - name: FALCO_K8S_NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
      {{- if or (not .Values.driver.enabled) (and .Values.driver.loader.enabled .Values.driver.loader.initContainer.enabled) }}
        - name: SKIP_DRIVER_LOADER
          value:
      {{- end }}
      {{- if and .Values.driver.enabled (eq .Values.driver.kind "ebpf") }}
        - name: FALCO_BPF_PROBE
          value: {{ .Values.driver.ebpf.path }}
      {{- end }}
      {{- range $key, $value := .Values.extra.env }}
        - name: "{{ $key }}"
          value: "{{ $value }}"
      {{- end }}
      {{- if .Values.falco.webserver.enabled }}
      livenessProbe:
        initialDelaySeconds: {{ .Values.healthChecks.livenessProbe.initialDelaySeconds }}
        timeoutSeconds: {{ .Values.healthChecks.livenessProbe.timeoutSeconds }}
        periodSeconds: {{ .Values.healthChecks.livenessProbe.periodSeconds }}
        httpGet:
          path: {{ .Values.falco.webserver.k8sHealthzEndpoint }}
          port: {{ .Values.falco.webserver.listenPort }}
          {{- if .Values.falco.webserver.sslEnabled }}
          scheme: HTTPS
          {{- end }}
      readinessProbe:
        initialDelaySeconds: {{ .Values.healthChecks.readinessProbe.initialDelaySeconds }}
        timeoutSeconds: {{ .Values.healthChecks.readinessProbe.timeoutSeconds }}
        periodSeconds: {{ .Values.healthChecks.readinessProbe.periodSeconds }}
        httpGet:
          path: {{ .Values.falco.webserver.k8sHealthzEndpoint }}
          port: {{ .Values.falco.webserver.listenPort }}
          {{- if .Values.falco.webserver.sslEnabled }}
          scheme: HTTPS
          {{- end }}
      {{- end }}
      volumeMounts:
        - mountPath: /root/.falco
          name: root-falco-fs
        - mountPath: /host/proc
          name: proc-fs
        {{- if and .Values.driver.enabled (not .Values.driver.loader.initContainer.enabled) }}
          readOnly: true
        - mountPath: /host/boot
          name: boot-fs
          readOnly: true
        - mountPath: /host/lib/modules
          name: lib-modules
        - mountPath: /host/usr
          name: usr-fs
          readOnly: true
        - mountPath: /host/etc
          name: etc-fs
          readOnly: true
        {{- end}}  
        {{- if and .Values.driver.enabled (eq .Values.driver.kind "module") }}
        - mountPath: /host/dev
          name: dev-fs
          readOnly: true
        {{- end}}
        {{- if .Values.docker.enabled }}
        - mountPath: /host/var/run/docker.sock
          name: docker-socket
        {{- end}}
        {{- if .Values.containerd.enabled }}
        - mountPath: /host/run/containerd/containerd.sock
          name: containerd-socket
        {{- end}}
        {{- if and .Values.crio .Values.crio.enabled }}
        - mountPath: /host/run/crio/crio.sock
          name: crio-socket
        {{- end}}
        - mountPath: /etc/falco
          name: config-volume
        {{- if .Values.customRules }}
        - mountPath: /etc/falco/rules.d
          name: rules-volume
        {{- end }}
        {{- if and .Values.falco.grpc.enabled .Values.falco.grpc.unixSocketPath }}
        - mountPath: {{ include "falco.unixSocketDir" . }}
          name: grpc-socket-dir
        {{- end }}
        {{- if or .Values.falco.webserver.sslEnabled (and .Values.falco.grpc.enabled (not .Values.falco.grpc.unixSocketPath)) }}
        - mountPath: /etc/falco/certs
          name: certs-volume
          readOnly: true
        {{- end }}
        {{- with .Values.extra.volumeMounts }}
          {{- toYaml . | nindent 8 }}
        {{- end }}
  initContainers:
  {{- with .Values.extra.initContainers }}
    {{- toYaml .Values.extra.initContainers | nindent 8 }}
  {{- end }}
  {{- if .Values.driver.enabled -}}
  {{- if and .Values.driver.loader.enabled .Values.driver.loader.initContainer.enabled }}
    {{- include "falco.driverLoader.initContainer" . | nindent 4 }}
  {{- end -}}
  {{- end}}
  volumes:
    - name: root-falco-fs
      emptyDir: {}
    {{- if .Values.driver.enabled }}  
    - name: boot-fs
      hostPath:
        path: /boot
    - name: lib-modules
      hostPath:
        path: /lib/modules
    - name: usr-fs
      hostPath:
        path: /usr
    - name: etc-fs
      hostPath:
        path: /etc
    {{- end}}
    {{- if and .Values.driver.enabled (eq .Values.driver.kind "module") }}
    - name: dev-fs
      hostPath:
        path: /dev
    {{- end}}
    {{- if .Values.docker.enabled }}
    - name: docker-socket
      hostPath:
        path: {{ .Values.docker.socket }}
    {{- end}}
    {{- if .Values.containerd.enabled }}
    - name: containerd-socket
      hostPath:
        path: {{ .Values.containerd.socket }}
    {{- end}}
    {{- if and .Values.crio .Values.crio.enabled }}
    - name: crio-socket
      hostPath:
        path: {{ .Values.crio.socket }}
    {{- end}}
    - name: proc-fs
      hostPath:
        path: /proc
    - name: config-volume
      configMap:
        name: {{ include "falco.fullname" . }}
        items:
          - key: falco.yaml
            path: falco.yaml
          - key: falco_rules.yaml
            path: falco_rules.yaml
          - key: falco_rules.local.yaml
            path: falco_rules.local.yaml
          - key: application_rules.yaml
            path: rules.available/application_rules.yaml
          - key: k8s_audit_rules.yaml
            path: k8s_audit_rules.yaml
          - key: aws_cloudtrail_rules.yaml
            path: aws_cloudtrail_rules.yaml
    {{- if .Values.customRules }}
    - name: rules-volume
      configMap:
        name: {{ include "falco.fullname" . }}-rules
    {{- end }}
    {{- if and .Values.falco.grpc.enabled .Values.falco.grpc.unixSocketPath }}
    - name: grpc-socket-dir
      hostPath:
        path: {{ include "falco.unixSocketDir" . }}
    {{- end }}
    {{- if or .Values.falco.webserver.sslEnabled (and .Values.falco.grpc.enabled (not .Values.falco.grpc.unixSocketPath)) }}
    - name: certs-volume
      secret:
        {{- if .Values.certs.existingSecret }}
        secretName: {{ .Values.certs.existingSecret }}
        {{- else }}
        secretName: {{ include "falco.fullname" . }}-certs
        {{- end }}
    {{- end }}
    {{- with .Values.extra.volumes }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
{{- end -}}

{{- define "falco.driverLoader.initContainer" -}}
- name: {{ .Chart.Name }}-driver-loader
  image: {{ include "falco.driverLoader.image" . }}
  imagePullPolicy: {{ .Values.driver.loader.initContainer.image.pullPolicy }}
  {{- if eq .Values.driver.kind "module" }}
  securityContext:
    privileged: true
  {{- end }}
  volumeMounts:
    - mountPath: /root/.falco
      name: root-falco-fs
    - mountPath: /host/proc
      name: proc-fs
      readOnly: true
    - mountPath: /host/boot
      name: boot-fs
      readOnly: true
    - mountPath: /host/lib/modules
      name: lib-modules
    - mountPath: /host/usr
      name: usr-fs
      readOnly: true
    - mountPath: /host/etc
      name: etc-fs
      readOnly: true
  env:
  {{- if eq .Values.driver.kind "ebpf" }}
    - name: FALCO_BPF_PROBE
      value: {{ .Values.driver.ebpf.path }}
  {{- end }}
{{- end -}}