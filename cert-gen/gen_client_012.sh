echo "1. generate client keys"&&
cd root/ca/intermediate-client&&

openssl genrsa -out issuing-client/private/client-0.key.pem 2048&&
openssl genrsa -out issuing-client/private/client-1.key.pem 2048&&
openssl genrsa -out issuing-client/private/client-2.key.pem 2048&&

echo "2. creating certificate signing requests"&&
openssl req -config issuing-client/openssl_issuing_client.cnf -new -sha256 -key issuing-client/private/client-0.key.pem -out issuing-client/csr/client-0.csr.pem&&
openssl req -config issuing-client/openssl_issuing_client.cnf -new -sha256 -key issuing-client/private/client-1.key.pem -out issuing-client/csr/client-1.csr.pem&&
openssl req -config issuing-client/openssl_issuing_client.cnf -new -sha256 -key issuing-client/private/client-2.key.pem -out issuing-client/csr/client-2.csr.pem&&

echo "3. signing the certificates"&&
openssl ca -config issuing-client/openssl_issuing_client.cnf -extensions usr_cert -days 375 -notext -md sha256 -in issuing-client/csr/client-0.csr.pem -out issuing-client/certs/client-0.cert.pem&&
openssl ca -config issuing-client/openssl_issuing_client.cnf -extensions usr_cert -days 375 -notext -md sha256 -in issuing-client/csr/client-1.csr.pem -out issuing-client/certs/client-1.cert.pem&&
openssl ca -config issuing-client/openssl_issuing_client.cnf -extensions usr_cert -days 375 -notext -md sha256 -in issuing-client/csr/client-2.csr.pem -out issuing-client/certs/client-2.cert.pem&&

echo "4. verifing the certificates"&&
openssl x509 -noout -text -in issuing-client/certs/client-0.cert.pem&&
openssl x509 -noout -text -in issuing-client/certs/client-1.cert.pem&&
openssl x509 -noout -text -in issuing-client/certs/client-2.cert.pem&&

openssl verify -CAfile issuing-client/certs/ca-chain.cert.pem issuing-client/certs/client-0.cert.pem&&
openssl verify -CAfile issuing-client/certs/ca-chain.cert.pem issuing-client/certs/client-1.cert.pem&&
openssl verify -CAfile issuing-client/certs/ca-chain.cert.pem issuing-client/certs/client-2.cert.pem