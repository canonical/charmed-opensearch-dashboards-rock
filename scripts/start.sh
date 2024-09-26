#!/usr/bin/env bash

set -eux

NODE_NAME="${NODE_NAME:-node-0}"
NETWORK_HOST="${NETWORK_HOST:-_local_,_site_}"


function set_yaml_prop() {
    local target_file="${1}"
    local key="${2}"
    local value="${3}"

    /usr/bin/python3 /usr/bin/set_conf.py --file "${target_file}" --key "${key}" --value "${value}"
}

function network_host() {
    echo "[ \"_site_\", \"$(hostname -i)\" ]"
}

conf="${OPENSEARCH_DASHBOARDS_PATH_CONF}/opensearch_dashboards.yml"

set_yaml_prop "${conf}" "server.host" "$(network_host)"
set_yaml_prop "${conf}" "path.data" "${OPENSEARCH_DASHBOARDS_VARLIB}/data"
set_yaml_prop "${conf}" "path.logs" "${OPENSEARCH_DASHBOARDS_VARLOG}/logs"

cat "${conf}"

exec /usr/bin/setpriv \
  --clear-groups \
  --reuid OPENSEARCH_DASHBOARDS \
  --regid OPENSEARCH_DASHBOARDS \
  -- "${OPENSEARCH_DASHBOARDS_BIN}"/OPENSEARCH_DASHBOARDS
