echo "1. creating drectories: "&&
cd root/ca/intermediate-client&& 
mkdir issuing-client&&
cd issuing-client&&
mkdir certs crl csr newcerts private&&
touch index.txt&&
echo 1000 > serial&&
echo 1000 > crlnumber&&
cd ..&& # root/ca/intermediate-client 
cd ..&& # root/ca 
cd ..&& # root/
cd ..&& # 
cp openssl_issuing_client.cnf root/ca/intermediate-client/issuing-client/openssl_issuing_client.cnf&&

echo "2. creating the issuing-client key: "&&
cd root/ca/intermediate-client&&
openssl genrsa -out issuing-client/private/issuing-client.key.pem 4096&&

echo "3. create the issuing-client certificate sign request"&&
openssl req -config issuing-client/openssl_issuing_client.cnf -new -sha256 -key issuing-client/private/issuing-client.key.pem -out issuing-client/csr/issuing-client.csr.pem&&

echo "4. create the issuing-client certificate"&&
openssl ca -config openssl_intermediate_client.cnf -extensions v3_issuing_ca -days 3650 -notext -md sha256 -in issuing-client/csr/issuing-client.csr.pem -out issuing-client/certs/issuing-client.cert.pem&&

echo "5. verify the issuing-client certificate"&&
openssl x509 -noout -text -in issuing-client/certs/issuing-client.cert.pem&&
openssl verify -CAfile certs/ca-chain.cert.pem issuing-client/certs/issuing-client.cert.pem&&

echo "6. create the certificate chain file:"&&
cat issuing-client/certs/issuing-client.cert.pem certs/ca-chain.cert.pem > issuing-client/certs/ca-chain.cert.pem&&
echo "certificate chain file creation successful!"