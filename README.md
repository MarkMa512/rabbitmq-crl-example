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
      - IssuingClient CA (**CRL generating CA**)
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


  - I have tried using **both EXTERNAL and PLAIN** authetication mechanism, but the behavior is the **same**. 
  - I have also attempted to convert the CRL file from PEM format to **DER format** as `issuing-client.crl` using commands `covert_crl_pem_to_der.sh` under `cert-gen`. Again, there is no difference. 
      - As per the [ssl_crl_cache](https://www.erlang.org/doc/man/ssl_crl_cache.html#DATA%20TYPES) documentation, a DER formmatted CRL is needed. 

The CRL file `issuing-client.crl.pem` is generated using the issuing-client CA, with commands `reovoke_client-2.sh` under `cert-gen`. 

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

3. Attempted to modify the `advanced.config` file to that in `advanced_cache.erl`: 
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
                    {crl_cache, {ssl_crl_cache, {internal, [{dir, "/home/crl/issuing-client.crl.pem"}]}}}
                  ]}
   ]}
].
```
This would lead to the following errors in the broker

```
[error] <0.818.0> Failed to start Ranch listener {acceptor,{0,0,0,0,0,0,0,0},5671} in ranch_ssl:listen(#{connection_type => supervisor,handshake_timeout => 5000,max_connections => infinity,num_acceptors => 10,num_conns_sups => 1,socket_opts => [{cacerts,'...'},{key,'...'},{cert,'...'},{ip,{0,0,0,0,0,0,0,0}},{port,5671},inet6,{backlog,128},{nodelay,true},{linger,{true,0}},{exit_on_close,false},{versions,['tlsv1.3','tlsv1.2','tlsv1.1',tlsv1]}]}) for reason no_cert (no certificate provided; see cert, certfile, sni_fun or sni_hosts options)
[error] <0.818.0> 
[error] <0.815.0>     supervisor: {<0.815.0>,ranch_listener_sup}
[error] <0.815.0>     errorContext: start_error
[error] <0.815.0>     reason: {listen_error,{acceptor,{0,0,0,0,0,0,0,0},5671},no_cert}
[error] <0.815.0>     offender: [{pid,undefined},
[error] <0.815.0>                {id,ranch_acceptors_sup},
[error] <0.815.0>                {mfargs,
[error] <0.815.0>                    {ranch_acceptors_sup,start_link,
[error] <0.815.0>                        [{acceptor,{0,0,0,0,0,0,0,0},5671},ranch_ssl,logger]}},
[error] <0.815.0>                {restart_type,permanent},
[error] <0.815.0>                {significant,false},
[error] <0.815.0>                {shutdown,infinity},
[error] <0.815.0>                {child_type,supervisor}]
[error] <0.815.0> 
[error] <0.818.0>   crasher:
[error] <0.818.0>     initial call: supervisor:ranch_acceptors_sup/1
[error] <0.818.0>     pid: <0.818.0>
[error] <0.818.0>     registered_name: []
[error] <0.818.0>     exception exit: {listen_error,{acceptor,{0,0,0,0,0,0,0,0},5671},no_cert}
[error] <0.818.0>       in function  ranch_acceptors_sup:listen_error/5 (src/ranch_acceptors_sup.erl, line 96)
[error] <0.818.0>       in call from ranch_acceptors_sup:start_listen_sockets/5 (src/ranch_acceptors_sup.erl, line 54)
[error] <0.818.0>       in call from ranch_acceptors_sup:init/1 (src/ranch_acceptors_sup.erl, line 34)
[error] <0.818.0>       in call from supervisor:init/1 (supervisor.erl, line 330)
[error] <0.818.0>       in call from gen_server:init_it/2 (gen_server.erl, line 423)
[error] <0.818.0>       in call from gen_server:init_it/6 (gen_server.erl, line 390)
[error] <0.818.0>     ancestors: [<0.815.0>,<0.813.0>,<0.812.0>,rabbit_sup,<0.221.0>]
[error] <0.818.0>     message_queue_len: 0
[error] <0.818.0>     messages: []
[error] <0.818.0>     links: [<0.815.0>]
[error] <0.818.0>     dictionary: []
[error] <0.818.0>     trap_exit: true
[error] <0.818.0>     status: running
[error] <0.818.0>     heap_size: 4185
[error] <0.818.0>     stack_size: 29
[error] <0.818.0>     reductions: 8641
[error] <0.818.0>   neighbours:
[error] <0.818.0> 
[error] <0.813.0>     supervisor: {<0.813.0>,ranch_embedded_sup}
[error] <0.813.0>     errorContext: start_error
[error] <0.813.0>     reason: {shutdown,
[error] <0.813.0>                 {failed_to_start_child,ranch_acceptors_sup,
[error] <0.813.0>                     {listen_error,{acceptor,{0,0,0,0,0,0,0,0},5671},no_cert}}}
[error] <0.813.0>     offender: [{pid,undefined},
[error] <0.813.0>                {id,{ranch_listener_sup,{acceptor,{0,0,0,0,0,0,0,0},5671}}},
[error] <0.813.0>                {mfargs,
[error] <0.813.0>                    {ranch_listener_sup,start_link,
[error] <0.813.0>                        [{acceptor,{0,0,0,0,0,0,0,0},5671},
[error] <0.813.0>                         ranch_ssl,
[error] <0.813.0>                         #{connection_type => supervisor,
[error] <0.813.0>                           handshake_timeout => 5000,
[error] <0.813.0>                           max_connections => infinity,num_acceptors => 10,
[error] <0.813.0>                           num_conns_sups => 1,
[error] <0.813.0>                           socket_opts =>
[error] <0.813.0>                               [{ip,{0,0,0,0,0,0,0,0}},
[error] <0.813.0>                                {port,5671},
[error] <0.813.0>                                inet6,
[error] <0.813.0>                                {backlog,128},
[error] <0.813.0>                                {nodelay,true},
[error] <0.813.0>                                {linger,{true,0}},
[error] <0.813.0>                                {exit_on_close,false},
[error] <0.813.0>                                {versions,
[error] <0.813.0>                                    ['tlsv1.3','tlsv1.2','tlsv1.1',tlsv1]}]},
[error] <0.813.0>                         rabbit_connection_sup,[]]}},
[error] <0.813.0>                {restart_type,permanent},
[error] <0.813.0>                {significant,false},
[error] <0.813.0>                {shutdown,infinity},
[error] <0.813.0>                {child_type,supervisor}]
[error] <0.813.0> 
[error] <0.812.0>     supervisor: {<0.812.0>,tcp_listener_sup}
[error] <0.812.0>     errorContext: start_error
[error] <0.812.0>     reason: {shutdown,
[error] <0.812.0>                 {failed_to_start_child,
[error] <0.812.0>                     {ranch_listener_sup,{acceptor,{0,0,0,0,0,0,0,0},5671}},
[error] <0.812.0>                     {shutdown,
[error] <0.812.0>                         {failed_to_start_child,ranch_acceptors_sup,
[error] <0.812.0>                             {listen_error,
[error] <0.812.0>                                 {acceptor,{0,0,0,0,0,0,0,0},5671},
[error] <0.812.0>                                 no_cert}}}}}
[error] <0.812.0>     offender: [{pid,undefined},
[error] <0.812.0>                {id,{ranch_embedded_sup,{acceptor,{0,0,0,0,0,0,0,0},5671}}},
[error] <0.812.0>                {mfargs,
[error] <0.812.0>                    {ranch_embedded_sup,start_link,
[error] <0.812.0>                        [{acceptor,{0,0,0,0,0,0,0,0},5671},
[error] <0.812.0>                         ranch_ssl,
[error] <0.812.0>                         #{connection_type => supervisor,
[error] <0.812.0>                           handshake_timeout => 5000,
[error] <0.812.0>                           max_connections => infinity,num_acceptors => 10,
[error] <0.812.0>                           num_conns_sups => 1,
[error] <0.812.0>                           socket_opts =>
[error] <0.812.0>                               [{ip,{0,0,0,0,0,0,0,0}},
[error] <0.812.0>                                {port,5671},
[error] <0.812.0>                                inet6,
[error] <0.812.0>                                {backlog,128},
[error] <0.812.0>                                {nodelay,true},
[error] <0.812.0>                                {linger,{true,0}},
[error] <0.812.0>                                {exit_on_close,false},
[error] <0.812.0>                                {versions,
[error] <0.812.0>                                    ['tlsv1.3','tlsv1.2','tlsv1.1',tlsv1]}]},
[error] <0.812.0>                         rabbit_connection_sup,[]]}},
[error] <0.812.0>                {restart_type,permanent},
[error] <0.812.0>                {significant,false},
[error] <0.812.0>                {shutdown,infinity},
[error] <0.812.0>                {child_type,supervisor}]
```
4. Attempted to modify the `advanced.config` file to that in `advanced_hashed.erl`: 

```
[
  {rabbit, [
     {ssl_listeners, [5671]},
     {ssl_options, [{cacertfile,"/home/rabbitmq-certs/test-certs/ca-chain.cert.pem"},
                      {certfile,"/home/rabbitmq-certs/test-certs/server.cert.pem"},
                      {keyfile,"/home/rabbitmq-certs/test-certs/server.key.pem"},
                      {verify,verify_peer},
                      {fail_if_no_peer_cert,true},
                      {crl_check, true},
                      {crl_cache, {ssl_crl_hash_dir, {internal, [{dir, "/home/crl/"}]}}}]}
   ]}
].
```

The same error of `Failed to start Ranch listener` will appear. 

## References and Acknowlegdment 

A special thank to [Luke Bakken](https://github.com/lukebakken) for his continued guidance and support through discussion [here](https://groups.google.com/g/rabbitmq-users/c/sLXfiBGaKfQ)

The x509 certificate and CRL generation script took referrnce from Jamie Nguyen's comprehensive guide on [OpenSSL Certificate Authority](https://jamielinux.com/docs/openssl-certificate-authority/index.html).


I also took referrence from the following websites and repositories: 

  - [erl crl example](https://github.com/Vagabond/erl_crl_example)

  - [erlang-tls-misc](https://github.com/lukebakken/erlang-tls-misc)

  - [RabbitMQ CRL Configuration](https://serverfault.com/questions/752233/rabbitmq-crl-configuration)

  - [erlang/otp/ssl_crl_SUITE.erl](https://github.com/erlang/otp/blob/master/lib/ssl/test/ssl_crl_SUITE.erl)

  - [Kubernetes RabbitMQ Certificate Revocation List](https://greduan.com/blog/2022/02/02/kubernetes-rabbitmq-certificate-revocation-list)
