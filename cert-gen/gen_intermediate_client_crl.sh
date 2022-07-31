echo "1. create CRL at Intermediate-Client CA"
cd root/ca&&
openssl ca -config intermediate-client/openssl_intermediate_client.cnf -gencrl -out intermediate-client/crl/intermediate-client.crl.pem&&

echo "2. verify the CRL"
openssl crl -in intermediate-client/crl/intermediate-client.crl.pem -noout -text&&

echo "3. create crl chain: root crl + intermediate crl"
cat intermediate-client/crl/intermediate-client.crl.pem crl/root.crl.pem > intermediate-client/crl/crl-chain.crl.pem&&
echo "crl chain file creation successful!"