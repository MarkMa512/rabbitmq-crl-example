echo "@tear_down_rabbit-s.sh"
echo "1. remove container rabbit-s..."
docker rm -f rabbit-s
echo "1. remove container rabbit-s...done!"
echo "2. remove rabbit-net-s..."
docker network rm rabbit-net-s
echo "2. remove rabbit-net-s...done!"
echo "teardown completed!"
echo "======================================"