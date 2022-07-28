# RabbitMQ Certificate Revocation List (CRL) Mechanism

## About the Project 
This is my attempt in implementing CRL Mechanism on RabbitMQ to block client with certificate that has been revoked. My approach was to use the advanced.config file and erlang's native support for CRL. 

## Directories
- `/broker` contains shell scripts, server certificates, crl file, `rabbitmq.conf` and `advanced.config` files needed to set up the rabbitmq container. 
- `/cert-gen` containes OpenSSL config files and shell scripts that automates the certificates and crl generation process 
- `/client-0` a python client that connect to the broker via SSL with client-0 certificate 
- `/client-2` a python client that connect to the broker via SSL with client-2 certifictae (revoked)

## Prerequisite: 
This project is tested on: 
- RHEL 8.5 and macOS 12.4
- with git installed
- with Docker installed
- with Python 3.10 and pika 1.2.1  / Python 3.8.8 and pika 1.2.0 installed

## Geting Started 

### Start the broker 
1. Clone the repository to your computer: 

```
git clone https://github.com/MarkMa512/rabbitmq-crl-example.git
```

2. Enter the broker directory: 
```
cd rabbitmq-crl-example/broker
```

3. Run the `start_cluster_rabbit-s.sh` script:
```
sh start_cluster_rabbit-s.sh
```

4. Run the `apply_useraccess.sh` script: 
```
sh apply_useraccess.sh
```

### Reload certificates/crl/configuration files and reset the broker 
If you have modified the certificates/crl/configuration files, please run the following script to reset the broker
```
sh reload_reset.sh 
```

### Verify the configuration files and certificate location inside the broker 
To verify the locations of certificates, as well as the contents for the config files, run 
```
sh verify_rabbit-s.sh
```

### Start the client 
1. Enter the client directory: 

2. 

## Certificate Structure and Generation
The certificates are self-signed for testing purposes only. 

The certificate generation are done using a series of shell script in `/cert-gen` folder, in the following hierachy: 

ROOT CA
  - IntermediateClient CA
    - IssuingClient CA (CRL generating CA)
      - client-0  
      - client-1  
      - client-2  
  - Intermediate Server CA 
    - IssuingServer CA 
      - server 


If you wish to regenerate the certificates to modify things like common name, please follow the following steps: 

1. Modify all the openssl_xxxx.cnf


## Existing Issue 

Despite my best attempts, owing to my limited understanding of erlang, RabbitMQ and CRL, this mechanism does not seem to be working. 

The CRL file `issuing-client.crl.pem` is generated using the issuing-client CA, with commands `reovoke_client-2.sh`. 

Despite of using the `advanced.config` to enable the CRL checking funtion: 

```
[
  {rabbit, [
     {ssl_listeners, [5671]},
     {ssl_options, [
                    {cacertfile,"/home/rabbitmq-certs/test-certs/ca-chain.cert.pem"},
                    {certfile,"/home/rabbitmq-certs/test-certs/server.cert.pem"},
                    {keyfile,"/home/rabbitmq-certs/test-certs/server.key.pem"},
                    {verify,verify_peer},
                    {fail_if_no_peer_cert,true}]},
                    {crl_check, true},
                    {crl_cache, {ssl_crl_cache, {internal, [{dir, "/home/crl/issuing-client.crl.pem"}]}}}
   ]}
].
```

`client-2` is still able to connect to broker: 

```
INFO:pika.adapters.utils.connection_workflow:Pika version 1.2.1 connecting to ('::1', 5671, 0, 0)
INFO:pika.adapters.utils.io_services_utils:Socket connected: <socket.socket fd=6, family=AddressFamily.AF_INET6, type=SocketKind.SOCK_STREAM, proto=6, laddr=('::1', 40554, 0, 0), raddr=('::1', 5671, 0, 0)>
INFO:pika.adapters.utils.io_services_utils:SSL handshake completed successfully: <ssl.SSLSocket fd=6, family=AddressFamily.AF_INET6, type=SocketKind.SOCK_STREAM, proto=6, laddr=('::1', 40554, 0, 0), raddr=('::1', 5671, 0, 0)>
INFO:pika.adapters.utils.connection_workflow:Streaming transport linked up: (<pika.adapters.utils.io_services_utils._AsyncSSLTransport object at 0x7f8a6ad88e80>, _StreamingProtocolShim: <SelectConnection PROTOCOL transport=<pika.adapters.utils.io_services_utils._AsyncSSLTransport object at 0x7f8a6ad88e80> params=<ConnectionParameters host=localhost port=5671 virtual_host=/ ssl=True>>).
INFO:pika.adapters.utils.connection_workflow:AMQPConnector - reporting success: <SelectConnection OPEN transport=<pika.adapters.utils.io_services_utils._AsyncSSLTransport object at 0x7f8a6ad88e80> params=<ConnectionParameters host=localhost port=5671 virtual_host=/ ssl=True>>
INFO:pika.adapters.utils.connection_workflow:AMQPConnectionWorkflow - reporting success: <SelectConnection OPEN transport=<pika.adapters.utils.io_services_utils._AsyncSSLTransport object at 0x7f8a6ad88e80> params=<ConnectionParameters host=localhost port=5671 virtual_host=/ ssl=True>>
INFO:pika.adapters.blocking_connection:Connection workflow succeeded: <SelectConnection OPEN transport=<pika.adapters.utils.io_services_utils._AsyncSSLTransport object at 0x7f8a6ad88e80> params=<ConnectionParameters host=localhost port=5671 virtual_host=/ ssl=True>>
INFO:pika.adapters.blocking_connection:Created channel=1

This is activity_log.py: monitoring routing key '#' in exchange 'logging_topic' ...

```

## Resources 
I took referrence from the following websites and 

  - [erl crl example](https://github.com/Vagabond/erl_crl_example)

  - [erlang-tls-misc](https://github.com/lukebakken/erlang-tls-misc)

  - [RabbitMQ CRL Configuration](https://serverfault.com/questions/752233/rabbitmq-crl-configuration)

  - [erlang/otp/ssl_crl_SUITE.erl](https://github.com/erlang/otp/blob/master/lib/ssl/test/ssl_crl_SUITE.erl)

  - [Kubernetes RabbitMQ Certificate Revocation List](https://greduan.com/blog/2022/02/02/kubernetes-rabbitmq-certificate-revocation-list)

## Acknowledgements 
A special thank to [Luke Bakken](https://github.com/lukebakken) for his continued guidance and support through discussion [here](https://groups.google.com/g/rabbitmq-users/c/sLXfiBGaKfQ)

The x509 certificate and CRL generation script took referrnce from Jamie Nguyen's comprehensive guide on [OpenSSL Certificate Authority](https://jamielinux.com/docs/openssl-certificate-authority/index.html).
