#!/bin/sh
set -e

# Install envsubst if not present (for Alpine-based images)
command -v envsubst >/dev/null 2>&1 || apk add --no-cache gettext

# Render templates
if [ -f /outputs.conf.template ]; then
  envsubst < /outputs.conf.template > /opt/splunkforwarder/etc/system/local/outputs.conf
fi
if [ -f /inputs.conf.template ]; then
  envsubst < /inputs.conf.template > /opt/splunkforwarder/etc/system/local/inputs.conf
fi

# Start Splunk UF with the original entrypoint logic
exec /sbin/entrypoint.sh start-service#!/bin/sh
set -e

mkdir -p /opt/splunkforwarder/etc/system/local/

# Start Splunk UF in the foreground to keep the container running
/opt/splunkforwarder/bin/splunk start --accept-license --answer-yes --no-prompt

# Optionally, tail the main log to keep the container alive and show logs
tail -F /opt/splunkforwarder/var/log/splunk/splunkd.log