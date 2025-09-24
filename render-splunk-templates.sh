#!/bin/bash
# Render Splunk config templates using envsubst and secrets.env
set -e

# Load environment variables from secrets.env
set -a
. ./secrets.env
set +a

# Render inputs.conf
if [ -f splunkuf-config/inputs.conf.template ]; then
  envsubst < splunkuf-config/inputs.conf.template > splunkuf-config/inputs.conf
fi
# Render outputs.conf
if [ -f splunkuf-config/outputs.conf.template ]; then
  envsubst < splunkuf-config/outputs.conf.template > splunkuf-config/outputs.conf
fi

echo "Splunk config templates rendered."
