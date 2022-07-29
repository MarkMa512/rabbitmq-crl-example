% Reference: https://greduan.com/blog/2022/02/02/kubernetes-rabbitmq-certificate-revocation-list
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
                      {crl_cache, {ssl_crl_hash_dir, {internal, [{dir, "/home/crl/"}]}}}]}
   ]}
].