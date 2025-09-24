#!/bin/sh
# Render Splunk UF config templates using envsubst on the host
# Usage: ./render-splunkuf-config.sh

set -e

TEMPLATE_DIR="$(dirname "$0")"
RENDERED_DIR="$TEMPLATE_DIR/rendered"

mkdir -p "$RENDERED_DIR"

if [ -f "$TEMPLATE_DIR/outputs.conf.template" ]; then
  envsubst < "$TEMPLATE_DIR/outputs.conf.template" > "$RENDERED_DIR/outputs.conf"
  echo "Rendered outputs.conf"
fi
if [ -f "$TEMPLATE_DIR/inputs.conf.template" ]; then
  envsubst < "$TEMPLATE_DIR/inputs.conf.template" > "$RENDERED_DIR/inputs.conf"
  echo "Rendered inputs.conf"
fi
