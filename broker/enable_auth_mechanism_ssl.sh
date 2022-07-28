echo "@ enable_ssl_authen.sh"
echo "1. Enabling ssl authen plugin..."
docker exec -it rabbit-s rabbitmq-plugins enable rabbitmq_auth_mechanism_ssl&&
echo "1. Enabling ssl authen plugin...done!"
echo "enabling ssl authen plugin:completed!"
echo "======================================"