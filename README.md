# RabbitMQ Certificate Revocation List (CRL) Mechanism

## About The Project 
This is my attempt in implementing CRL Mechanism on RabbitMQ to block client with certificate that has been revoked, through advanced.config file. 

## Geting Started 
This project is done and tested on 
- RHEL 8.5 runing on VMware Player
- with Docker installed
- with Python 3.10 installed and pika 1.2.1  

Relevant changes may be needed for it to work on your device. 

## Certificate Generation and Structure
The certificate generation are done using a series of shell script in cert-gen folder

## Existing Issue 
The CRL machanism insdie RabbitMQ does not seem to be working. 

## Acknowledgements 
A special thank to [Luke Bakken](https://github.com/lukebakken) for his continued guidance and support through discussion [here](https://groups.google.com/g/rabbitmq-users/c/sLXfiBGaKfQ)

The x509 certificate and CRL generation script took referrnce from Jamie Nguyen's comprehensive guide on [OpenSSL Certificate Authority](https://jamielinux.com/docs/openssl-certificate-authority/index.html).
