echo "1. create CRL"
cd root/ca/intermediate-client&&
openssl ca -config issuing-client/openssl_issuing_client.cnf -gencrl -out issuing-client/crl/issuing-client.crl.pem&&

echo "2. revoke client-2"
openssl ca -config issuing-client/openssl_issuing_client.cnf -revoke issuing-client/certs/client-2.cert.pem

echo "3. re-create updated CRL"
openssl ca -config issuing-client/openssl_issuing_client.cnf -gencrl -out issuing-client/crl/issuing-client.crl.pem&&

echo "4. verify the CRL"
openssl crl -in issuing-client/crl/issuing-client.crl.pem -noout -text