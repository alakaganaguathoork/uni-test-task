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
{{- end -}}

{{- define "app.ingress.ingressClassName" -}}
nginx
{{- end -}}