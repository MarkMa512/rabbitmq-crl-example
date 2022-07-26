echo "1. creating drectories: "
cd root/ca/intermediate-server&& 
mkdir issuing-server&&
cd issuing-server&&
mkdir certs crl csr newcerts private&&
touch index.txt&&
echo 1000 > serial&&
echo 1000 > crlnumber&&
cd ..&& # root/ca/intermediate-server 
cd ..&& # root/ca 
cd ..&& # root/
cd ..&& # 
cp openssl_issuing_server.cnf root/ca/intermediate-server/issuing-server/openssl_issuing_server.cnf&&

echo "2. creating the issuing-server key: "&&
cd root/ca/intermediate-server&&
openssl genrsa -out issuing-server/private/issuing-server.key.pem 4096&&

echo "3. create the issuing-server certificate sign request"&&
openssl req -config issuing-server/openssl_issuing_server.cnf -new -sha256 -key issuing-server/private/issuing-server.key.pem -out issuing-server/csr/issuing-server.csr.pem&&

echo "4. create the issuing-server certificate"&&
openssl ca -config openssl_intermediate_server.cnf -extensions v3_issuing_ca -days 3650 -notext -md sha256 -in issuing-server/csr/issuing-server.csr.pem -out issuing-server/certs/issuing-server.cert.pem&&

echo "5. verify the issuing-server certificate"&& 
openssl x509 -noout -text -in issuing-server/certs/issuing-server.cert.pem&&
openssl verify -CAfile certs/ca-chain.cert.pem issuing-server/certs/issuing-server.cert.pem&&

echo "6. create the certificate chain file:"&& 
cat issuing-server/certs/issuing-server.cert.pem certs/ca-chain.cert.pem > issuing-server/certs/ca-chain.cert.pem&&
echo "certificate chain file creation successful!"