{{- define "app.image" -}}
{{- if .Values.image -}}
{{ .Values.image.repository }}/{{ .Values.image.name }}:{{ .Values.image.tag | default .Chart.AppVersion }}
{{- end -}}
{{- end -}}

###
## Ingress
###
# Specify ingress annotations
{{- define "app.ingress.annotations" -}}
kubernetes.io/ingress.class: nginx
nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
{{- end -}}

{{- define "app.ingress.ingressClassName" -}}
nginx
{{- end -}}