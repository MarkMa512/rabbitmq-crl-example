echo "@reload_reset_rabbit-s.sh"
echo "1. copy certificates and config files to rabbit-s: "
sh ./rabbit-1/reload_crt_crl_config.sh&&
echo "1. copy certificates and config files to rabbit-s: completed!"
echo "2. resetting rabbit-s:"
sh reset_rabbit-s.sh&&
echo "2. resetting rabbit-s:completed!"
echo "reload reset rabbit-s completed!"
echo "======================================"
