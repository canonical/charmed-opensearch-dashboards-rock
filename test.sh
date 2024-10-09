#!/usr/bin/env bash

version="$(cat rockcraft.yaml | yq .version)"

# create first cm_node container
container_0_id=$(docker run \
    -d --rm -it \
    -e NODE_NAME=cm0 \
    -e INITIAL_CM_NODES=cm0 \
    -p 9200:9200 \
    --name cm0 \
    charmed-opensearch-dashboards:"${version}")
container_0_ip=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' "${container_0_id}")

# wait a bit for it to fully initialize
sleep 15s

# create data/voting_only node container
container_1_id=$(docker run \
    -d --rm -it \
    -e NODE_NAME=data1 \
    -e SEED_HOSTS="${container_0_ip}" \
    -e NODE_ROLES=data,voting_only \
    -p 9201:9200 \
    --name data1 \
    charmed-opensearch-dashboards:"${version}")
container_1_ip=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' "${container_1_id}")

# wait a bit for it to fully initialize
sleep 15s

# create 2nd cm_node container
docker run \
    -d --rm -it \
    -e NODE_NAME=cm1 \
    -e SEED_HOSTS="${container_0_ip},${container_1_ip}" \
    -e INITIAL_CM_NODES="cm0,cm1" \
    -p 9202:9200 \
    --name cm1 \
    charmed-opensearch-dashboards:"${version}"

# wait a bit for it to fully initialize
sleep 15s
