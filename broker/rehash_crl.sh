cd rabbit-1

# method 1
# This does not work for crl chain file, but works for individual crl files 
# got error: bad_crl,invalid_signature
openssl rehash crl

# method 2
# the crl chain Does not seemed to work after hashing for rabbitmq 
# got error: bad_crls,no_relevant_crls
# for file in *.pem; do ln -s "$file" "$(openssl crl -hash -noout -in "$file")".0; done

# method 3
# does not work on RHEL; no output
# c_rehash crl 