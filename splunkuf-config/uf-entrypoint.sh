#!/bin/sh
set -e

/opt/splunkforwarder/bin/splunk start --accept-license --answer-yes --no-prompt

tail -F /opt/splunkforwarder/var/log/splunk/splunkd.log
