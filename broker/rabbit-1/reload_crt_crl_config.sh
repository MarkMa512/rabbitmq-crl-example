echo "@reload_crt_crl_config.sh"
BASEDIR=$(dirname "$0")&&
echo "1. clear existing certificate and CRL directory: "
sh $BASEDIR/clear_crt_crl_dir.sh&&
echo "1. clear existing certificate and CRL directory: completed!"
echo "2. copy new cetificates, crl and configurations into rabbit-s: "
sh $BASEDIR/copy_crt_crl_cnf.sh&&
echo "2. copy new cetificates, crl and configurations into rabbit-s: completed!"
echo "reload certificate, CRL and config files completed!"
echo "======================================"