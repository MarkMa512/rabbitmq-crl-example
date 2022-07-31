cd rabbit-1
# This does not work for crl chain file 
# openssl rehash crl

for file in *.pem; do ln -s "$file" "$(openssl crl -hash -noout -in "$file")".0; done

# does not work on RHEL; no output
# c_rehash crl 