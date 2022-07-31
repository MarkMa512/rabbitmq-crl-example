echo "1. create CRL at ROOT CA"
cd root/ca&&
openssl ca -config openssl_root.cnf -gencrl -out crl/root.crl.pem&&

echo "2. verify the CRL"
openssl crl -in crl/root.crl.pem -noout -text