echo "@reset_rabbit-s.sh"
echo "1. stop, reset and restart the node..."
docker exec -it rabbit-s rabbitmqctl stop_app&&
docker exec -it rabbit-s rabbitmqctl reset&&
docker exec -it rabbit-s rabbitmqctl start_app&&
echo "1. stop, reset and restart the node...done!"
echo "reset rabbit-s completed!"
echo "remeber to re-apply user access!"
echo "======================================"