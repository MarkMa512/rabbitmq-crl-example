echo "@verify_rabbit-s.sh"
echo "List rabbit-s/home/crl..."
echo "--------------------------------------------------"
docker exec rabbit-s ls "home/crl"&&
echo "=================================================="
echo "List rabbit-s/home/rabbitmq-certs/..."
echo "--------------------------------------------------"
docker exec rabbit-s ls "home/rabbitmq-certs/"&&
echo "=================================================="
echo "Display rabbit-s/etc/rabbitmq/rabbitmq.conf..."
echo "--------------------------------------------------"
docker exec rabbit-s cat /etc/rabbitmq/rabbitmq.conf&&
echo "=================================================="
echo "Display rabbit-s/etc/rabbitmq/advanced.config..."
echo "--------------------------------------------------"
docker exec rabbit-s cat /etc/rabbitmq/advanced.config&&
echo "=================================================="