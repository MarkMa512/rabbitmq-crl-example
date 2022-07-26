echo "@ start_cluster_rabbit-s.sh"
echo "1. creating network rabbit-net-s..."
docker network create -d bridge rabbit-net-s --attachable&&
echo "1. Creating network rabbit-net-s...done!"
echo "2. creating rabbit-s container:"
sh ./rabbit-1/start_node.sh&&
echo "2. creating rabbit-s container: completed!"
echo "3. sleep 10s for rabbit-s to boot-up..."
sleep 10s&&
echo "3. sleep 10s for rabbit-s to boot-up...done!"
echo "4. verify the setup:"
sh verify_rabbit-s.sh&&
echo "4.  verify the setup:completed!"
echo "rabbitmq cluster setup completed!"
echo "======================================"