echo "@verify_rabbit-s.sh"
echo "List rabbit-s/home/crl..."
echo "--------------------------------------------------"
docker exec rabbit-s ls "home/crl"&&
echo "Verify the crl file..."
docker exec rabbit-s openssl crl -in home/crl/crl-chain.crl.pem -noout -text&&
echo "=================================================="
echo "List rabbit-s/home/rabbitmq-certs/test-certs..."
echo "--------------------------------------------------"
docker exec rabbit-s ls "home/rabbitmq-certs/test-certs"&&
echo "=================================================="
echo "Display rabbit-s/etc/rabbitmq/rabbitmq.conf..."
echo "--------------------------------------------------"
docker exec rabbit-s cat /etc/rabbitmq/rabbitmq.conf&&
echo ""
echo "=================================================="
echo "Display rabbit-s/etc/rabbitmq/advanced.config..."
echo "--------------------------------------------------"
docker exec rabbit-s cat /etc/rabbitmq/advanced.config&&
echo "=================================================="
echo "Display users and permissions..."
echo "--------------------------------------------------"
docker exec rabbit-s rabbitmqctl list_users&&
docker exec rabbit-s rabbitmqctl list_permissions&&
echo "=================================================="
echo "Display enabled plugins..."
echo "--------------------------------------------------"
docker exec rabbit-s rabbitmq-plugins list&&
echo "=================================================="