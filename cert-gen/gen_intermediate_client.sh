echo "1. creating drectories: "
cd root/ca&&
mkdir intermediate-client&&
cd intermediate-client&&
mkdir certs crl csr newcerts private&&
touch index.txt&&
echo 1000 > serial&&
echo 1000 > crlnumber&&
cd ..&& # root/ca 
cd ..&& # root/
cd ..&& # 
cp openssl_intermediate_client.cnf root/ca/intermediate-client/openssl_intermediate_client.cnf&&

echo "2. creating the intermediate-client key:"&&
cd root/ca&&
openssl genrsa -out intermediate-client/private/intermediate-client.key.pem 4096&&

echo "3. create the intermediate-client certificate sign request"&&
openssl req -config intermediate-client/openssl_intermediate_client.cnf -new -sha256 -key intermediate-client/private/intermediate-client.key.pem -out intermediate-client/csr/intermediate-client.csr.pem&&

echo "4. create the intermediate-client certificate"&&
openssl ca -config openssl_root.cnf -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in intermediate-client/csr/intermediate-client.csr.pem -out intermediate-client/certs/intermediate-client.cert.pem&&

echo "5. verify the intermediate-client certificate"&&
openssl x509 -noout -text -in intermediate-client/certs/intermediate-client.cert.pem&&
openssl verify -CAfile certs/ca.cert.pem intermediate-client/certs/intermediate-client.cert.pem&&

echo "6. create the certificate chain file:"&&
cat intermediate-client/certs/intermediate-client.cert.pem certs/ca.cert.pem > intermediate-client/certs/ca-chain.cert.pem&&
echo "certificate chain file creation successful!"