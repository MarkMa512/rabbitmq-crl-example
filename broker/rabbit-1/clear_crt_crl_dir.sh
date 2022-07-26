echo "@clear_crt_crl_dir.sh"
echo "1. deleting the current certificates in rabbit-s..."
docker exec -it rabbit-s rm -r /home/rabbitmq-certs&&
echo "1. deleting the current certificates in rabbit-s...done!"
echo "2. deleting the current crls in rabbit-s..."
docker exec -it rabbit-s rm -r /home/crl&&
echo "2. deleting the current crl in rabbit-s...done!"
echo "clear certificate and crl directories completed!"
echo "======================================"