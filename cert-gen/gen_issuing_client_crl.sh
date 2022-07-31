echo "1. create CRL at issuing client CA"
cd root/ca/intermediate-client&&
openssl ca -config issuing-client/openssl_issuing_client.cnf -gencrl -out issuing-client/crl/issuing-client.crl.pem&&

echo "2. verify the CRL"
openssl crl -in issuing-client/crl/issuing-client.crl.pem -noout -text