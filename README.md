# RabbitMQ Certificate Revocation List (CRL) Mechanism

## About the Project 
This is my attempt in implementing CRL Mechanism on RabbitMQ to block client with certificate that has been revoked. My approach was to use the `advanced.config` file and erlang's native support for CRL. 

### Directories
- `/broker` contains shell scripts, server certificates, crl file, `rabbitmq.conf` and `advanced.config` files needed to set up the rabbitmq container. 
- `/cert-gen` contains OpenSSL config files and shell scripts that automates the certificates and crl generation process 
- `/client-0` a python client that connect to the broker via SSL with client-0 certificate 
- `/client-2` a python client that connect to the broker via SSL with client-2 certificate (**revoked**)

## Aim 
The aim for this project is to use CRL mechanism to **block client-2**, with an **revoked client certificate**, from connecting to the rabbitMQ broker. 

## Prerequisite: 
This project is tested on:
- RHEL 8.5 / macOS 12.4
- with git installed
- with Docker installed
- with Python 3.10 and pika 1.2.1  / Python 3.8.8 and pika 1.2.0 installed

## Geting Started 

### Before you begin: Authetication Mechanism 
**EXTERNAL** Authentication Mechanism using x509 certifictae peer verification has been **enabled by default** in this repository. If you wish to use **SASL PLAIN** authetication mechanism, please comment out line 6: `auth_mechanisms.1 = EXTERNAL` in the `rabbitmq.conf` file. 

```
# enable this line for external authetication via certificates and SSL
auth_mechanisms.1 = EXTERNAL
```

For more information regarding RabbitMQ Authetication Mechanism, please refer to [rabbitmq/access-control#mechanisms](https://www.rabbitmq.com/access-control.html#mechanisms)

### Start the RabbitMQ broker container
1. using terminal, clone the repository to your computer: 
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

#### EXTERNAL Authentication Mechanism

**By default**, the broker has **EXTERNAL** authetication mechanism enabled in `rabbitmq.conf` files. Follow step 4 and 5. 

4. Run the `enable_auth_mechanism_ssl.sh`
```
sh enable_auth_mechanism_ssl.sh
```

5. Run the `apply_useraccess_external.sh` script: 
```
sh apply_useraccess_external.sh
```

#### PLAIN Authetication Mechanism 
If you wish to use **PLAIN** authetication mechanismonly, besides commenting out the line in `rabbitmq.conf` as per mentioned in [Before you begin: Authetication Mechanism](https://github.com/MarkMa512/rabbitmq-crl-example#before-you-begin-authetication-mechanism), follow step 6

6. Run the `apply_useraccess_plain.sh` script: 
```
sh apply_useraccess_plain.sh
```


### Reload certificates/crl/configuration files and reset the broker 
If you have modified the certificates/crl/configuration files, please run the following script to reset the broker
```
sh reload_reset_rabbit-s.sh 
```
Please re-apply user acess accordingly. 
However, you are still advised to tear down the broker setup and re-start the broker. 

### Verify the configuration files and certificate location inside the broker 
To verify the locations of certificates, as well as the contents for the config files, run 
```
sh verify_rabbit-s.sh
```

### Teardown the broker setup
If you are experiencing some errors or failures, you can tear down the entier setup with the following script: 
```
sh tear_down_rabbit-s.sh
```


### Start the client 
1. Enter the client directory: 
```
cd client-0
```

2. Run the python client: 
```
python activity_log_external.py
```
```
python activity_log_plain.py
```
Note: 

a. Please run the client according to the the authetication mechanism. 

  i. EXTERNAL: `activity_log_external.py`

  ii. PLAIN: `activity_log_plain.py`

b. You may need to use `python3` or `python3.10` etc instead of just `python`, depends on your Python installation configuration. 

## Certificate Structure and Generation

The certificates are **self-signed** for **testing purposes only**. 

The certificate generation are done using a series of shell script in `/cert-gen` folder, in the following hierachy: 

  - **ROOT CA**
    - IntermediateClient CA
      - IssuingClient CA
        - client-0  
        - client-1  
        - client-2 (**revoked**)
    - Intermediate Server CA 
      - IssuingServer CA 
        - server 

### Generating the certificate
If you wish to regenerate the certificates to modify things like common name, please follow the following steps: 

1. Modify all the `openssl_xxxx.cnf` at line 10 to that matching the path of repo on your machine
```
dir               = /path/to/the/repo/rabbitmq-crl-example/cert-gen/root/ca
```
2. Run the command in the following sequence, and input relevant details when prompted: 
```
sh gen_root.sh 
```
```
sh gen_intermediate_server.sh
```
```
sh gen_issuing_server.sh 
```
```
sh gen_server.sh 
```
```
sh gen_intermediate_client.sh 
```
```
sh gen_issuing_client.sh 
```
```
sh gen_client_012.sh
```

The complete CA chain files, as well as the client/server certificates for the clients and the server are generated automatically at the following directotires: 
```
cert-gen\root\ca\intermediate-client\issuing-client\certs
```
```
cert-gen\root\ca\intermediate-client\issuing-server\certs
```


The keys are located at: 
```
cert-gen\root\ca\intermediate-client\issuing-client\private
```
```
cert-gen\root\ca\intermediate-client\issuing-server\private
```



## Existing Issue 

Despite my best attempts, owing to my limited understanding of erlang, RabbitMQ and CRL, the CRL mechanism does not seem to be working. 



The CRL file `issuing-client.crl.pem` is generated using the issuing-client CA, with commands `reovoke_client-2.sh` under `cert-gen`. 

Despite of using the `advanced.config` to enable the CRL checking funtion: 

### Test Case 1: using *ssl_crl_cache* and `issuing-client.crl`
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
                    {crl_cache, {ssl_crl_cache, {internal, [{dir, "/home/crl/issuing-client.crl"}]}}}
   ]}
].
```

`client-2` is **still able to connect to broker**, shown as below.

```
INFO:pika.adapters.utils.connection_workflow:Pika version 1.2.1 connecting to ('::1', 5671, 0, 0)
INFO:pika.adapters.utils.io_services_utils:Socket connected: <socket.socket fd=6, family=AddressFamily.AF_INET6, type=SocketKind.SOCK_STREAM, proto=6, laddr=('::1', 40554, 0, 0), raddr=('::1', 5671, 0, 0)>
INFO:pika.adapters.utils.io_services_utils:SSL handshake completed successfully: <ssl.SSLSocket fd=6, family=AddressFamily.AF_INET6, type=SocketKind.SOCK_STREAM, proto=6, laddr=('::1', 40554, 0, 0), raddr=('::1', 5671, 0, 0)>
INFO:pika.adapters.utils.connection_workflow:Streaming transport linked up: (<pika.adapters.utils.io_services_utils._AsyncSSLTransport object at 0x7f8a6ad88e80>, _StreamingProtocolShim: <SelectConnection PROTOCOL transport=<pika.adapters.utils.io_services_utils._AsyncSSLTransport object at 0x7f8a6ad88e80> params=<ConnectionParameters host=localhost port=5671 virtual_host=/ ssl=True>>).
INFO:pika.adapters.utils.connection_workflow:AMQPConnector - reporting success: <SelectConnection OPEN transport=<pika.adapters.utils.io_services_utils._AsyncSSLTransport object at 0x7f8a6ad88e80> params=<ConnectionParameters host=localhost port=5671 virtual_host=/ ssl=True>>
INFO:pika.adapters.utils.connection_workflow:AMQPConnectionWorkflow - reporting success: <SelectConnection OPEN transport=<pika.adapters.utils.io_services_utils._AsyncSSLTransport object at 0x7f8a6ad88e80> params=<ConnectionParameters host=localhost port=5671 virtual_host=/ ssl=True>>
INFO:pika.adapters.blocking_connection:Connection workflow succeeded: <SelectConnection OPEN transport=<pika.adapters.utils.io_services_utils._AsyncSSLTransport object at 0x7f8a6ad88e80> params=<ConnectionParameters host=localhost port=5671 virtual_host=/ ssl=True>>
INFO:pika.adapters.blocking_connection:Created channel=1

```

### Test Case 2: 

Attempts tp use *ssl_crl_hash_dir*  and `issuing-client.crl`: Both client cannot connect

```
[
  {rabbit, [
     {ssl_listeners, [5671]},
     {ssl_options, [  
                      {cacertfile,"/home/rabbitmq-certs/test-certs/ca-chain.cert.pem"},
                      {certfile,"/home/rabbitmq-certs/test-certs/server.cert.pem"},
                      {keyfile,"/home/rabbitmq-certs/test-certs/server.key.pem"},
                      {verify,verify_peer},
                      {fail_if_no_peer_cert,true},
                      {crl_check, true},
                      {crl_cache, {ssl_crl_hash_dir, {internal, [{dir, "/home/crl/"}]}}}
                     ]}
   ]}
].
```

Broker Output: 
```
[notice] <0.1085.0> TLS server: In state wait_cert at ssl_handshake.erl:2077 generated SERVER ALERT: Fatal - Bad Certificate
[notice] <0.1085.0>  - {bad_crls,no_relevant_crls}
```
Client-0: 
```
pika.exceptions.IncompatibleProtocolError: StreamLostError: ("Stream connection lost: SSLError(1, '[SSL: SSLV3_ALERT_BAD_CERTIFICATE] sslv3 alert bad certificate (_ssl.c:2548)')",)
```

Client-2: 
```
pika.exceptions.IncompatibleProtocolError: StreamLostError: ("Stream connection lost: SSLError(1, '[SSL: SSLV3_ALERT_BAD_CERTIFICATE] sslv3 alert bad certificate (_ssl.c:2548)')",)
```

### Test Case 3: 
Attempts tp use *ssl_crl_hash_dir*  and `issuing-client.crl.pem`


Broker: 
```
[notice] <0.1062.0> TLS server: In state wait_cert at ssl_handshake.erl:2077 generated SERVER ALERT: Fatal - Bad Certificate
[notice] <0.1062.0>  - {bad_crls,no_relevant_crls}

```

Client-0: 
```
pika.exceptions.IncompatibleProtocolError: StreamLostError: ("Stream connection lost: SSLError(1, '[SSL: SSLV3_ALERT_BAD_CERTIFICATE] sslv3 alert bad certificate (_ssl.c:2548)')",)
```

Client-2: 
```
pika.exceptions.IncompatibleProtocolError: StreamLostError: ("Stream connection lost: SSLError(1, '[SSL: SSLV3_ALERT_BAD_CERTIFICATE] sslv3 alert bad certificate (_ssl.c:2548)')",)
```

## Other Attempts and Findings

1. Enable both the PLAIN and EXTERNAL Autehitcaiton Mechanism, with both user acess enabled: 

```
auth_mechanisms.1 = EXTERNAL
auth_mechanisms.1 = PLAIN
```

Attempting to connect via client-0: `activity_log_external.py` and `activity_log_plain.py`, would lead to failure: 

For `activity_log_external.py`: 

```
INFO:pika.adapters.utils.connection_workflow:Pika version 1.2.1 connecting to ('::1', 5671, 0, 0)
INFO:pika.adapters.utils.io_services_utils:Socket connected: <socket.socket fd=6, family=AddressFamily.AF_INET6, type=SocketKind.SOCK_STREAM, proto=6, laddr=('::1', 41966, 0, 0), raddr=('::1', 5671, 0, 0)>
ERROR:pika.adapters.utils.io_services_utils:SSL do_handshake failed: error=ConnectionResetError(104, 'Connection reset by peer'); <ssl.SSLSocket fd=6, family=AddressFamily.AF_INET6, type=SocketKind.SOCK_STREAM, proto=6, laddr=('::1', 41966, 0, 0)>
ConnectionResetError: [Errno 104] Connection reset by peer
ERROR:pika.adapters.utils.connection_workflow:Attempt to create the streaming transport failed: ConnectionResetError(104, 'Connection reset by peer'); 'localhost'/(<AddressFamily.AF_INET6: 10>, <SocketKind.SOCK_STREAM: 1>, 6, '', ('::1', 5671, 0, 0)); ssl=True
ERROR:pika.adapters.utils.connection_workflow:AMQPConnector - reporting failure: AMQPConnectorTransportSetupError: ConnectionResetError(104, 'Connection reset by peer')
INFO:pika.adapters.utils.connection_workflow:Pika version 1.2.1 connecting to ('127.0.0.1', 5671)
INFO:pika.adapters.utils.io_services_utils:Socket connected: <socket.socket fd=7, family=AddressFamily.AF_INET, type=SocketKind.SOCK_STREAM, proto=6, laddr=('127.0.0.1', 57630), raddr=('127.0.0.1', 5671)>
ERROR:pika.adapters.utils.io_services_utils:SSL do_handshake failed: error=ConnectionResetError(104, 'Connection reset by peer'); <ssl.SSLSocket fd=7, family=AddressFamily.AF_INET, type=SocketKind.SOCK_STREAM, proto=6, laddr=('127.0.0.1', 57630)>
ConnectionResetError: [Errno 104] Connection reset by peer
ERROR:pika.adapters.utils.connection_workflow:Attempt to create the streaming transport failed: ConnectionResetError(104, 'Connection reset by peer'); 'localhost'/(<AddressFamily.AF_INET: 2>, <SocketKind.SOCK_STREAM: 1>, 6, '', ('127.0.0.1', 5671)); ssl=True
ERROR:pika.adapters.utils.connection_workflow:AMQPConnector - reporting failure: AMQPConnectorTransportSetupError: ConnectionResetError(104, 'Connection reset by peer')
ERROR:pika.adapters.utils.connection_workflow:AMQP connection workflow failed: AMQPConnectionWorkflowFailed: 2 exceptions in all; last exception - AMQPConnectorTransportSetupError: ConnectionResetError(104, 'Connection reset by peer'); first exception - AMQPConnectorTransportSetupError: ConnectionResetError(104, 'Connection reset by peer').
ERROR:pika.adapters.utils.connection_workflow:AMQPConnectionWorkflow - reporting failure: AMQPConnectionWorkflowFailed: 2 exceptions in all; last exception - AMQPConnectorTransportSetupError: ConnectionResetError(104, 'Connection reset by peer'); first exception - AMQPConnectorTransportSetupError: ConnectionResetError(104, 'Connection reset by peer')
ERROR:pika.adapters.blocking_connection:Connection workflow failed: AMQPConnectionWorkflowFailed: 2 exceptions in all; last exception - AMQPConnectorTransportSetupError: ConnectionResetError(104, 'Connection reset by peer'); first exception - AMQPConnectorTransportSetupError: ConnectionResetError(104, 'Connection reset by peer')
ERROR:pika.adapters.blocking_connection:Error in _create_connection().
ConnectionResetError: [Errno 104] Connection reset by peer
```

For `activity_log_plain.py`: 

```
INFO:pika.adapters.utils.connection_workflow:Pika version 1.2.1 connecting to ('::1', 5671, 0, 0)
INFO:pika.adapters.utils.io_services_utils:Socket connected: <socket.socket fd=6, family=AddressFamily.AF_INET6, type=SocketKind.SOCK_STREAM, proto=6, laddr=('::1', 41976, 0, 0), raddr=('::1', 5671, 0, 0)>
ERROR:pika.adapters.utils.io_services_utils:SSL do_handshake failed: error=SSLEOFError(8, 'EOF occurred in violation of protocol (_ssl.c:997)'); <ssl.SSLSocket fd=6, family=AddressFamily.AF_INET6, type=SocketKind.SOCK_STREAM, proto=6, laddr=('::1', 41976, 0, 0)>
ssl.SSLEOFError: EOF occurred in violation of protocol (_ssl.c:997)
ERROR:pika.adapters.utils.connection_workflow:Attempt to create the streaming transport failed: SSLEOFError(8, 'EOF occurred in violation of protocol (_ssl.c:997)'); 'localhost'/(<AddressFamily.AF_INET6: 10>, <SocketKind.SOCK_STREAM: 1>, 6, '', ('::1', 5671, 0, 0)); ssl=True
ERROR:pika.adapters.utils.connection_workflow:AMQPConnector - reporting failure: AMQPConnectorTransportSetupError: SSLEOFError(8, 'EOF occurred in violation of protocol (_ssl.c:997)')
INFO:pika.adapters.utils.connection_workflow:Pika version 1.2.1 connecting to ('127.0.0.1', 5671)
INFO:pika.adapters.utils.io_services_utils:Socket connected: <socket.socket fd=7, family=AddressFamily.AF_INET, type=SocketKind.SOCK_STREAM, proto=6, laddr=('127.0.0.1', 57640), raddr=('127.0.0.1', 5671)>
ERROR:pika.adapters.utils.io_services_utils:SSL do_handshake failed: error=SSLEOFError(8, 'EOF occurred in violation of protocol (_ssl.c:997)'); <ssl.SSLSocket fd=7, family=AddressFamily.AF_INET, type=SocketKind.SOCK_STREAM, proto=6, laddr=('127.0.0.1', 57640)>
ssl.SSLEOFError: EOF occurred in violation of protocol (_ssl.c:997)
ERROR:pika.adapters.utils.connection_workflow:Attempt to create the streaming transport failed: SSLEOFError(8, 'EOF occurred in violation of protocol (_ssl.c:997)'); 'localhost'/(<AddressFamily.AF_INET: 2>, <SocketKind.SOCK_STREAM: 1>, 6, '', ('127.0.0.1', 5671)); ssl=True
ERROR:pika.adapters.utils.connection_workflow:AMQPConnector - reporting failure: AMQPConnectorTransportSetupError: SSLEOFError(8, 'EOF occurred in violation of protocol (_ssl.c:997)')
ERROR:pika.adapters.utils.connection_workflow:AMQP connection workflow failed: AMQPConnectionWorkflowFailed: 2 exceptions in all; last exception - AMQPConnectorTransportSetupError: SSLEOFError(8, 'EOF occurred in violation of protocol (_ssl.c:997)'); first exception - AMQPConnectorTransportSetupError: SSLEOFError(8, 'EOF occurred in violation of protocol (_ssl.c:997)').
ERROR:pika.adapters.utils.connection_workflow:AMQPConnectionWorkflow - reporting failure: AMQPConnectionWorkflowFailed: 2 exceptions in all; last exception - AMQPConnectorTransportSetupError: SSLEOFError(8, 'EOF occurred in violation of protocol (_ssl.c:997)'); first exception - AMQPConnectorTransportSetupError: SSLEOFError(8, 'EOF occurred in violation of protocol (_ssl.c:997)')
ERROR:pika.adapters.blocking_connection:Connection workflow failed: AMQPConnectionWorkflowFailed: 2 exceptions in all; last exception - AMQPConnectorTransportSetupError: SSLEOFError(8, 'EOF occurred in violation of protocol (_ssl.c:997)'); first exception - AMQPConnectorTransportSetupError: SSLEOFError(8, 'EOF occurred in violation of protocol (_ssl.c:997)')
ERROR:pika.adapters.blocking_connection:Error in _create_connection().
ssl.SSLEOFError: EOF occurred in violation of protocol (_ssl.c:997)

```

**No Logs** are observed on the Broker side. 

2. Using EXTERNAL Authenticaion, use 2 instances of client-0: `activity_log_external.py` to connect to the broker: 

Both instances are able to connect to the broker simultaneously. The logs of the broker are as follows: 

```
[info] <0.1013.0> accepting AMQP connection <0.1013.0> (IP Address)
[debug] <0.1013.0> auth mechanism TLS extracted username 'CN=client-0,OU=crlTesting,O=crlTesting,ST=ProvinceName,C=US' from peer certificate
[debug] <0.1013.0> Raw client connection hostname during authN phase: {0,0,0,0,0,65##5,4##50,2}
[debug] <0.1013.0> Resolved client hostname during authN phase: ::ffff:IP Address
[debug] <0.1013.0> User 'CN=client-0,OU=crlTesting,O=crlTesting,ST=ProvinceName,C=US' authenticated successfully by backend rabbit_auth_backend_internal
[info] <0.1013.0> connection <0.1013.0> (IP Address): user 'CN=client-0,OU=crlTesting,O=crlTesting,ST=ProvinceName,C=US' authenticated and granted access to vhost '/'
[info] <0.1053.0> accepting AMQP connection <0.1053.0> (IP Address)
[debug] <0.1053.0> auth mechanism TLS extracted username 'CN=client-0,OU=crlTesting,O=crlTesting,ST=ProvinceName,C=US' from peer certificate
[debug] <0.1053.0> Raw client connection hostname during authN phase: {0,0,0,0,0,65##5,4##50,2}
[debug] <0.1053.0> Resolved client hostname during authN phase: ::ffff:IP Address
[debug] <0.1053.0> User 'CN=client-0,OU=crlTesting,O=crlTesting,ST=ProvinceName,C=US' authenticated successfully by backend rabbit_auth_backend_internal
[info] <0.1053.0> connection <0.1053.0> (IP Address): user 'CN=client-0,OU=crlTesting,O=crlTesting,ST=ProvinceName,C=US' authenticated and granted access to vhost '/'
```

The above test was done using PLAIN authentication mechanism, the behaviour is very similar where by 2 instances of client-0 `activity_log_plain.py` can connect to the broker simoutaneously. 


## References and Acknowlegdment 

A special thank to [Luke Bakken](https://github.com/lukebakken) for his continued guidance and support through discussion [here](https://groups.google.com/g/rabbitmq-users/c/sLXfiBGaKfQ)

The x509 certificate and CRL generation script took referrnce from Jamie Nguyen's comprehensive guide on [OpenSSL Certificate Authority](https://jamielinux.com/docs/openssl-certificate-authority/index.html).


I also took referrence from the following websites and repositories: 

  - [erl crl example](https://github.com/Vagabond/erl_crl_example)

  - [erlang-tls-misc](https://github.com/lukebakken/erlang-tls-misc)

  - [RabbitMQ CRL Configuration](https://serverfault.com/questions/752233/rabbitmq-crl-configuration)

  - [erlang/otp/ssl_crl_SUITE.erl](https://github.com/erlang/otp/blob/master/lib/ssl/test/ssl_crl_SUITE.erl)

  - [Kubernetes RabbitMQ Certificate Revocation List](https://greduan.com/blog/2022/02/02/kubernetes-rabbitmq-certificate-revocation-list)

  - [openssl crl](https://www.mkssoftware.com/docs/man1/openssl_crl.1.asp)

  - [B.4. CRL Extensions](https://access.redhat.com/documentation/en-us/red_hat_certificate_system/9/html/administration_guide/crl_extensions)

  - [Support crl_cache in conf-style configuration](https://github.com/rabbitmq/rabbitmq-server/issues/2338)

https://stackoverflow.com/questions/51479571/erlang-check-pem-certificate-is-not-revoked-with-crl-file
https://access.redhat.com/documentation/en-us/red_hat_update_infrastructure/2.1/html/administration_guide/chap-red_hat_update_infrastructure-administration_guide-certification_revocation_list_crl

crl chain generation 
https://stackoverflow.com/questions/43662445/unable-to-get-certificate-crl

https://stackoverflow.com/questions/25889341/what-is-the-equivalent-of-unix-c-rehash-command-script-on-linux

https://github.com/erlang/otp/blob/master/lib/ssl/test/ssl_crl_SUITE.erl

https://github.com/erlang/otp/blob/master/lib/public_key/src/pubkey_crl.erl

https://www.erlang.org/doc/man/ssl.html

```
ssl_crl_hash_dir
This module makes use of a directory where CRLs are stored in files named by the hash of the issuer name.

The file names consist of eight hexadecimal digits followed by .rN, where N is an integer, e.g. 1a2b3c4d.r0. For the first version of the CRL, N starts at zero, and for each new version, N is incremented by one. The OpenSSL utility c_rehash creates symlinks according to this pattern.

For a given hash value, this module finds all consecutive .r* files starting from zero, and those files taken together make up the revocation list. CRL files whose nextUpdate fields are in the past, or that are issued by a different CA that happens to have the same name hash, are excluded.
```

https://github.com/erlang/otp/issues/5300