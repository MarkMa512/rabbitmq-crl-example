echo "1. generate server key"&&
cd root/ca/intermediate-server&&
openssl genrsa -out issuing-server/private/server.key.pem 2048&&

echo "2. generate certificate signing request"&&
openssl req -config issuing-server/openssl_issuing_server.cnf -new -sha256 -key issuing-server/private/server.key.pem -out issuing-server/csr/server.csr.pem&&

echo "3. generate server certificate"&&
openssl ca -config issuing-server/openssl_issuing_server.cnf -extensions server_cert -days 375 -notext -md sha256 -in issuing-server/csr/server.csr.pem -out issuing-server/certs/server.cert.pem&&

echo "4. verify the certificate"&& 
openssl x509 -noout -text  -in issuing-server/certs/server.cert.pem&&
openssl verify -CAfile issuing-server/certs/ca-chain.cert.pem issuing-server/certs/server.cert.pem
