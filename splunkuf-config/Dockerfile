FROM splunk/universalforwarder:9.0.5

USER root
RUN apt-get update && apt-get install -y gettext && rm -rf /var/lib/apt/lists/*
USER splunk

# Entrypoint and config templates will be mounted by docker-compose
