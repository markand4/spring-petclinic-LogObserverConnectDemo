#!/bin/sh
# One-liner: Source secrets.env, render configs, and restart Splunk UF

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Source secrets.env
set -a
. "$PROJECT_DIR/secrets.env"
set +a

echo "Rendering Splunk UF configs..."
cd "$SCRIPT_DIR"
./render-splunkuf-config.sh

cd "$PROJECT_DIR"
echo "Restarting Splunk UF container..."
docker-compose up -d splunkuf

echo "Done."
