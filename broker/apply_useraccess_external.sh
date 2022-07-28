#!/usr/bin/env bashguestuse
echo "@apply_useraccess.sh"
echo "1. applying user access for client-2 ..."
docker exec -it rabbit-s rabbitmqctl add_user "CN=client-2,OU=crlTesting,O=crlTesting,ST=ProvinceName,C=US" test123!&&
docker exec -it rabbit-s rabbitmqctl set_user_tags "CN=client-2,OU=crlTesting,O=crlTesting,ST=ProvinceName,C=US" administrator&&
docker exec -it rabbit-s rabbitmqctl change_password "CN=client-2,OU=crlTesting,O=crlTesting,ST=ProvinceName,C=US" test123!&&
docker exec -it rabbit-s rabbitmqctl set_permissions -p "/" "CN=client-2,OU=crlTesting,O=crlTesting,ST=ProvinceName,C=US" "." "." ".*"&&
echo "1. applying user access for client-2 ...done!"
echo "2. applying user access for client-0 ..."
docker exec -it rabbit-s rabbitmqctl add_user "CN=client-0,OU=crlTesting,O=crlTesting,ST=ProvinceName,C=US" test123!&&
docker exec -it rabbit-s rabbitmqctl set_user_tags "CN=client-0,OU=crlTesting,O=crlTesting,ST=ProvinceName,C=US" administrator&&
docker exec -it rabbit-s rabbitmqctl change_password "CN=client-0,OU=crlTesting,O=crlTesting,ST=ProvinceName,C=US" test123!&&
docker exec -it rabbit-s rabbitmqctl set_permissions -p "/" "CN=client-0,OU=crlTesting,O=crlTesting,ST=ProvinceName,C=US" "." "." ".*"&&
echo "2. applying user access for client-0 ...done!"
echo "apply user acess completed!"
echo "======================================"