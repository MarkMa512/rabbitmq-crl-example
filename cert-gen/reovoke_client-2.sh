echo "1. revoke client-2"
cd root/ca/intermediate-client&&
openssl ca -config issuing-client/openssl_issuing_client.cnf -revoke issuing-client/certs/client-2.cert.pem&&

echo "2. re-create updated CRL at issuing-client CA"
openssl ca -config issuing-client/openssl_issuing_client.cnf -gencrl -out issuing-client/crl/issuing-client.crl.pem&&

echo "3. verify the CRL"
openssl crl -in issuing-client/crl/issuing-client.crl.pem -noout -text&&