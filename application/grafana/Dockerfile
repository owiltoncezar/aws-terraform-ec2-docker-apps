FROM grafana/grafana:latest

# Copiar os arquivos de provisionamento para o contêiner
COPY ./provisioning /etc/grafana/provisioning

# Copiar os dashboards para o contêiner
COPY ./dashboards /etc/grafana/dashboards

# Configurar o ponto de entrada para o Grafana
ENTRYPOINT ["/bin/bash", "-c", "/run.sh"]