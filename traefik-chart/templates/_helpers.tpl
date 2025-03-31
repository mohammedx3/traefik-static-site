{{/* templates/_helpers.tpl */}}
{{/* Generate basic labels */}}
{{- define "app.labels" -}}
app: {{ .Values.app.name }}
environment: {{ .Values.environment }}
{{- end }}

{{/* Generate selector labels */}}
{{- define "app.selectorLabels" -}}
app: {{ .Values.app.name }}
{{- end }}

{{/* Get domain from values */}}
{{- define "app.domain" -}}
{{ .Values.domain }}
{{- end }}