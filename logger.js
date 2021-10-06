var amqp = require('amqplib');

var localhost = "amqp://guest:guest@192.168.1.165:5672";
var queue = 'monitoringdata';

amqp.connect(localhost).then(function(connection) {
  process.once('SIGINT', function() { connection.close(); });
  return connection.createChannel().then(function(ch) {

    var channel = ch.assertQueue(queue, {durable: false});

    channel = channel.then(function(_qok) {
      return ch.consume(queue, function(msg) {
        console.log(" [x] Received %s", msg.content.toString());
      }, {no_ack: true});
    });

    return channel.then(function(_consumeOk) {
      console.log(" [*] Waiting for messages in %s. To exit press CTRL+C", queue);
    });
  });
}).catch(console.warn);

