import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import "package:dart_amqp/dart_amqp.dart";
import 'package:marquee/marquee.dart';

class Homepage extends StatefulWidget {
  Homepage();

  @override
  HomepageState createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  bool subscribed = false;
  bool emergencyStatus = false;
  String statusMessage = '';
  String alertMessage = '';
  Color color = Colors.lightGreen;
  Client client = Client();

  @override
  void initState() {
    super.initState();
    ConnectionSettings settings = ConnectionSettings(
        host: "192.168.1.165",
        authProvider: PlainAuthenticator("guest", "guest"));
    client = new Client(settings: settings);
    statusMessage = "Normal";
  }

  init() async {
    Channel channel = await client
        .channel(); // auto-connect to localhost:5672 using guest credentials
    Queue queue = await channel.queue("alertmessages");
    Consumer consumer = await queue.consume();
    consumer.listen((AmqpMessage message) {
      print(" [x] Received string: ${message.payloadAsString}");
      setState(() {
        color = Colors.deepOrangeAccent;
        statusMessage = "Danger";
        alertMessage = "Has been registered a dangerous value of " +
            message.payloadAsString +
            ", pay attention!";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: buildPage(),
              ),
            ],
          ),
        ));
  }

  buildPage() {
    if (subscribed) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.deepOrangeAccent),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Container(
                color: Colors.green.withOpacity(0.3),
                child: Lottie.asset("assets/images/volcano.json")),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Status:",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
            buildEmergencyMessage(),
            SizedBox(
              height: 10,
            ),
            addSlider()
          ],
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.deepOrangeAccent),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Press the button below to start to receive messages about the status of the volcano",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: OutlinedButton(
                      child: Text(
                        "START TO RECEIVE ALERT NOTIFICATIONS",
                        style: TextStyle(
                          color: Colors.deepOrangeAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          subscribed = !subscribed;
                        });
                        if (subscribed) {
                          init();
                        }
                      },
                    ))),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      );
    }
  }

  buildEmergencyMessage() {
    if (emergencyStatus) {
    } else {
      return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              statusMessage,
              style: TextStyle(fontSize: 18),
            ),
          ));
    }
  }

  addSlider() {
    if (alertMessage.isNotEmpty) {
      return Container(
        height: 30,
        width: 300,
        child: Marquee(
          text: alertMessage,
          style: TextStyle(fontWeight: FontWeight.bold),
          scrollAxis: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          blankSpace: 20.0,
          velocity: 100.0,
          pauseAfterRound: Duration(seconds: 1),
          startPadding: 10.0,
          accelerationDuration: Duration(seconds: 1),
          accelerationCurve: Curves.linear,
          decelerationDuration: Duration(milliseconds: 500),
          decelerationCurve: Curves.easeOut,
        ),
      );
    } else
      return Container();
  }

}
