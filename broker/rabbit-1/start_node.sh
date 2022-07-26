#!/usr/bin/env bash
echo "@ start_node.sh"
BASEDIR=$(dirname "$0")&&
echo "1. starting rabbit-s container..."
docker run -d --restart unless-stopped --net rabbit-net-s --hostname rabbit-s --name rabbit-s -p 8088:15672 -p 5671:5671 -p 5672:5672 rabbitmq:3-management&&
echo "1. starting rabbit-s container...done!"
echo "2. copying cert, CRL and configs to rabbit-s:"
sh $BASEDIR/copy_crt_crl_cnf.sh&&
echo "2. copying cert, CRL and configs to rabbit-s:completed!"
echo "start rabbit-s completed!"
echo "======================================"