cd root/ca/intermediate-client&&
echo "1. create crl chain: (root crl + intermediate client crl) + issuing client crl"
cat crl/crl-chain.crl.pem issuing-client/crl/issuing-client.crl.pem > issuing-client/crl/crl-chain.crl.pem&&
echo "crl chain file creation successful!"