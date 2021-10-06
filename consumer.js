var amqp = require('amqplib')

var localhost = 'amqp://guest:guest@192.168.1.165:5672';
var dataQueue = 'monitoringdata';
var messagesQueue = 'alertmessages'


amqp.connect(localhost).then(function (conn) {
    process.once('SIGINT', function () {
        conn.close();
    });
    return conn.createChannel().then(function (ch) {

        var ok = ch.assertQueue(dataQueue, {durable: false});

        ok = ok.then(function (_qok) {
            return ch.consume(dataQueue, function (msg) {

                var queueData = msg.content.toString();

                console.log("Value received from [monitoringdata]: " + msg.content);

                if (Number(msg.content) > 250) {
                    console.log("Dangerous value received: Publishing message on queue [alertmessages]")
                    publish_to_alert_queue(messagesQueue, queueData);
                }
            });
        });
        return ok.then(function (_consumeOk) {
            console.log(' [Waiting for messages on queue: monitoringdata]');
        });
    });
}).catch(console.warn);


async function publish_to_alert_queue(queue, data) {
    amqp.connect(localhost).then(function (connection) {
        return connection.createChannel().then(function (ch) {
            var channel = ch.assertQueue(messagesQueue, {durable: false});
            return channel.then(function () {
                ch.sendToQueue(messagesQueue, Buffer.from(data));
                return ch.close();
            });
        }).finally(function () {
            connection.close();
        })
    }).catch(console.log);
    console.log('Alert message published on [messagesQueue]');
}

