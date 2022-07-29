#!/usr/bin/env bashguestuse
echo "@apply_useraccess_plain.sh"
echo "1. applying user access for user ..."
docker exec -it rabbit-s rabbitmqctl add_user user test123!&&
docker exec -it rabbit-s rabbitmqctl set_user_tags user administrator&&
docker exec -it rabbit-s rabbitmqctl change_password user test123!&&
docker exec -it rabbit-s rabbitmqctl set_permissions -p "/" "user" "." "." ".*"&&
echo "1. applying user access for user ...done!"
echo "apply user acess completed!"
echo "======================================"