echo "1. creating drectories: "&&
mkdir root&&
cd root&&
mkdir ca&&
cd ca&&
mkdir certs crl newcerts private&&
touch index.txt&&
echo 1000 > serial&&
echo 1000 > crlnumber&&

echo "2. creating the root key: "&&
openssl genrsa -out private/ca.key.pem 4096&&

echo "3. create the root certificate"&&
cd ..&&
cd ..&&
cp openssl_root.cnf root/ca/openssl_root.cnf&&
cd root/ca&&
openssl req -config openssl_root.cnf -key private/ca.key.pem -new -x509 -days 7300 -sha256 -extensions v3_ca -out certs/ca.cert.pem&&

echo "4. verify root certificate "&&
openssl x509 -noout -text -in certs/ca.cert.pem