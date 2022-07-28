import pika
import ssl
import logging

logging.basicConfig(level=logging.INFO)

context = ssl.create_default_context(cafile="ca-chain.cert.pem") 

context.load_cert_chain("client-0.cert.pem", "client-0.key.pem")

credentials = pika.PlainCredentials('user', 'test123!')

ssl_options = pika.SSLOptions(context, "localhost")

conn_params = pika.ConnectionParameters(host= "localhost",
                                        port=5671,
                                        credentials=credentials,
                                        ssl_options=ssl_options, 
                                        heartbeat=3600, blocked_connection_timeout=3600
                                        )

connection = pika.BlockingConnection(conn_params)

channel = connection.channel()

exchangename= "logging_topic"
exchangetype= "topic"
channel.exchange_declare(exchange=exchangename, exchange_type=exchangetype, durable=True)

queue_name = 'Error'
channel.queue_declare(queue=queue_name, durable=True) 

routing_key = '*.error' 
channel.queue_bind(exchange=exchangename, queue=queue_name, routing_key=routing_key) 

queue_name = 'Activity_Log' 
channel.queue_declare(queue=queue_name, durable=True)

channel.queue_bind(exchange=exchangename, queue=queue_name, routing_key='#')

def check_setup():
    global connection, channel, hostname, port, exchangename, exchangetype

    if not is_connection_open(connection):
        connection = pika.BlockingConnection(pika.ConnectionParameters(host=hostname, port=port, heartbeat=3600, blocked_connection_timeout=3600))
    if channel.is_closed:
        channel = connection.channel()
        channel.exchange_declare(exchange=exchangename, exchange_type=exchangetype, durable=True)


def is_connection_open(connection):
    try:
        connection.process_data_events()
        return True
    except pika.exceptions.AMQPError as e:
        print("AMQP Error:", e)
        print("...creating a new connection.")
        return False