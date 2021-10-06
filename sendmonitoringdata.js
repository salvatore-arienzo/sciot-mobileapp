var amqp = require('amqplib');


var localhost = "amqp://guest:guest@192.168.1.165:5672";
var queue = 'monitoringdata';


exports.handler = function (context, event) {

    amqp.connect(localhost).then(function (connection) {
        return connection.createChannel().then(function (ch) {
            var channel = ch.assertQueue(queue, {durable: false});
            return channel.then(function () {
                var message = String(Math.round(Math.random() * (320 - 90)) + 90);
                ch.sendToQueue(queue, Buffer.from(message));
                return ch.close();
            });
        }).finally(function () {
            connection.close();
        })
    }).catch(console.log);
    context.callback('Sending message...');
};
