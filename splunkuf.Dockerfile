FROM splunk/universalforwarder:9.0.5

USER root
RUN chown -R splunk:splunk /opt/splunkforwarder
USER splunk