echo "@copy_crt_cnf_crl.sh"
BASEDIR=$(dirname "$0")&&
echo "1. copying cert to rabbit-s..."
docker cp $BASEDIR/certs/ rabbit-s:/home/rabbitmq-certs/&&
echo "1. copying cert to rabbit-s...done!"
echo "2. copying crls to rabbit-s..."
docker cp $BASEDIR/crl/ rabbit-s:/home/crl/&&
echo "2. copying crls to rabbit-s...done!"
echo "3. copying rabitmq.config to rabbit-s..."
docker cp $BASEDIR/configs/rabbitmq.conf rabbit-s:/etc/rabbitmq/rabbitmq.conf&&
echo "3. copying rabitmq.config to rabbit-s...done"
echo "4. copying advanced.config to rabbit-s..."
docker cp $BASEDIR/configs/advanced.config rabbit-s:/etc/rabbitmq/advanced.config&&
echo "4. copying advanced.config to rabbit-s...done"
echo "copy certificate, CRL and config files completed!"
echo "======================================"