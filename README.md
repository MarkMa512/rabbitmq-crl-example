# RabbitMQ Certificate Revocation List (CRL) Mechanism

## About The Project 
This is my attempt in implementing CRL Mechanism on RabbitMQ to block client with certificate that has been revoked, through advanced.config file. 

## Prerequisite: 
This project is done and tested on 
- RHEL 8.5 and macOS 12.4
- with Docker installed
- with Python 3.10 and pika 1.2.1  / Python 3.8.8 and pika 1.2.0 installed

## Geting Started 


## Certificate Structure
The certificates are self-signed for testing purposes. 
The certificate generation are done using a series of shell script in cert-gen folder, in the following structure: 

ROOT CA

    - IntermediateClient CA  
        - IssuingClient CA 
            - client-0 Certificate 
            - client-1 Certificate 
            - client-2 Certificate 
    - Intermediate Server CA 
        - IssuingServer CA 
            - server Certificate

## Existing Issue 
The CRL machanism insdie RabbitMQ does not seem to be working. 

## Acknowledgements 
A special thank to [Luke Bakken](https://github.com/lukebakken) for his continued guidance and support through discussion [here](https://groups.google.com/g/rabbitmq-users/c/sLXfiBGaKfQ)

The x509 certificate and CRL generation script took referrnce from Jamie Nguyen's comprehensive guide on [OpenSSL Certificate Authority](https://jamielinux.com/docs/openssl-certificate-authority/index.html).
