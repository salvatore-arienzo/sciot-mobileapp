# Volcano Monitoring 

## Introduction

The project's goal is to reproduce a system that is able to monitor volcanic activities and warn the user if the values are above thresholds. We are simulating the measurements that a gas sensor can perform on the surface of a volcano. For each measurement of the sensor, a value is sent to a RabbitMQ queue, to be processed. Then, a consumer read the values on the queue and since in the imminence of an eruption gasses emitted by a volcano have a drastic increase, if we find that one of the value is above our thresholds, we send an alert message to a second RabbitMQ queue that is monitored by the application clients that the users can use if they are nearby the volcano. 

## Architecture

![preview](https://github.com/salvatore-arienzo/sciot-volcanomonitoring/blob/main/appclient/assets/images/image.png)

## Installation

- Install [Docker](https://docs.docker.com/engine/install/) from the official website
- Install RabbitMQ:

```
 docker run -p 9000:15672  -p 1883:1883 -p 5672:5672  cyrilix/rabbitmq-mqtt
```
- Install Nuclio:

```
docker run -p 8070:8070 -v /var/run/docker.sock:/var/run/docker.sock -v /tmp:/tmp nuclio/dashboard:stable-amd64

```

- sendmonitoringdata.js: is generating random "gas" values and publising on the iot/monitoringdata queue. 
- logger.js: the logger function shows all the values that have been published on the iot/monitoringdata queue.
- consumer.js: is reading from the iot/monitoringdata queue and basing on the value found, it can send an alarm message to the iot/alertmessages queue.
- appclient: is the client application used by the users. Once the user open the application, it can choose to subscribe to the alert messages queue and start to receive notifications. Following, some screenshot from the app.


![preview](https://github.com/salvatore-arienzo/sciot-volcanomonitoring/blob/main/appclient/assets/images/preview.png)
