#!/usr/bin/env bash
TOP_DIR=$(cd $(dirname "$0") && pwd)
source $TOP_DIR/stackrc
SCRIPT="{\"script\":\"g.clear();g.loadGraphML(\\\"file:$WHALE_CONF_SOURCE\\\");\",\"params\":{}}"
curl -i -H 'Content-Type: application/json' -X POST -d "$SCRIPT" http://$HOST_IP:7474/db/data/ext/GremlinPlugin/graphdb/execute_script
