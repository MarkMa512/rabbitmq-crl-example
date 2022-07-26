#!/usr/bin/env bash
echo "@apply_policy.sh"
echo "1. applying policy..."
docker exec -it rabbit-s rabbitmqctl set_policy expiry ".*" '{"expires":86400000}' --apply-to queues
echo "1. applying policy...done!"
echo "apply policy completed!"
echo "======================================"