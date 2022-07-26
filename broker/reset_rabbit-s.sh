echo "@reset_rabbit-s.sh"
echo "1. stop, reset and restart the node..."
docker exec -it rabbit-s rabbitmqctl stop_app&&
docker exec -it rabbit-s rabbitmqctl reset&&
docker exec -it rabbit-s rabbitmqctl start_app&&
echo "1. stop, reset and restart the node...done!"
echo "2. re-applying user access: "
sh apply_useraccess.sh&&
echo "2. re-applying user access: completed!"
echo "reset rabbit-s completed!"
echo "======================================"