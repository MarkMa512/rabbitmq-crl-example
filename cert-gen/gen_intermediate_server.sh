echo "1. creating drectories: "
cd root/ca&&
mkdir intermediate-server&&
cd intermediate-server&&
mkdir certs crl csr newcerts private&&
touch index.txt&&
echo 1000 > serial&&
echo 1000 > crlnumber&&
cd ..&& # root/ca 
cd ..&& # root/
cd ..&& # 
cp openssl_intermediate_server.cnf root/ca/intermediate-server/openssl_intermediate_server.cnf&&

echo "2. creating the intermediate-server key: "&&
cd root/ca&&
openssl genrsa -out intermediate-server/private/intermediate-server.key.pem 4096&&

echo "3. create the intermediate-server certificate sign request"&&
openssl req -config intermediate-server/openssl_intermediate_server.cnf -new -sha256 -key intermediate-server/private/intermediate-server.key.pem -out intermediate-server/csr/intermediate-server.csr.pem&&

echo "4. create the intermediate-server certificate"&&
openssl ca -config openssl_root.cnf -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in intermediate-server/csr/intermediate-server.csr.pem -out intermediate-server/certs/intermediate-server.cert.pem&&

echo "5. verify the intermediate-server certificate" &&
openssl x509 -noout -text -in intermediate-server/certs/intermediate-server.cert.pem&&
openssl verify -CAfile certs/ca.cert.pem intermediate-server/certs/intermediate-server.cert.pem&&

echo "6. create the certificate chain file:" &&
cat intermediate-server/certs/intermediate-server.cert.pem certs/ca.cert.pem > intermediate-server/certs/ca-chain.cert.pem&&
echo "certificate chain file creation successful!"