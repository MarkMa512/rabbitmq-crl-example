echo "@apply_useraccess_external.sh"
echo "1. applying user access for client-2 (external)..."
docker exec -it rabbit-s rabbitmqctl add_user "CN=client-2,OU=crlTesting,O=crlTesting,ST=ProvinceName,C=US" test123!&&
docker exec -it rabbit-s rabbitmqctl set_user_tags "CN=client-2,OU=crlTesting,O=crlTesting,ST=ProvinceName,C=US" administrator&&
docker exec -it rabbit-s rabbitmqctl change_password "CN=client-2,OU=crlTesting,O=crlTesting,ST=ProvinceName,C=US" test123!&&
docker exec -it rabbit-s rabbitmqctl set_permissions -p "/" "CN=client-2,OU=crlTesting,O=crlTesting,ST=ProvinceName,C=US" "." "." ".*"&&
echo "1. applying user access for client-2 (external)...done!"
echo "2. applying user access for client-0 (external)..."
docker exec -it rabbit-s rabbitmqctl add_user "CN=client-0,OU=crlTesting,O=crlTesting,ST=ProvinceName,C=US" test123!&&
docker exec -it rabbit-s rabbitmqctl set_user_tags "CN=client-0,OU=crlTesting,O=crlTesting,ST=ProvinceName,C=US" administrator&&
docker exec -it rabbit-s rabbitmqctl change_password "CN=client-0,OU=crlTesting,O=crlTesting,ST=ProvinceName,C=US" test123!&&
docker exec -it rabbit-s rabbitmqctl set_permissions -p "/" "CN=client-0,OU=crlTesting,O=crlTesting,ST=ProvinceName,C=US" "." "." ".*"&&
echo "2. applying user access for client-0 (external)...done!"
echo "apply user acess completed!"
echo "======================================"