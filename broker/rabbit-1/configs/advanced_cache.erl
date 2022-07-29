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
                    {crl_cache, {ssl_crl_cache, {internal, [{dir, "/home/crl/issuing-client.crl"}]}}}
                  ]}
   ]}
].