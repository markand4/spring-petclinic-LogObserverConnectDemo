#!/bin/sh
# Clean wrapper entrypoint for Splunk UF: runs default entrypoint only
exec /sbin/entrypoint.sh "$@"
