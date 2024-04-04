import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sensor Data in Degrees',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(title: 'Sensor Data Display'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title});

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double? _roll; // To store the roll value
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  @override
  void initState() {
    super.initState();
    // Listening to accelerometer events
    _streamSubscriptions.add(
      accelerometerEvents
          .transform(
        StreamTransformer.fromHandlers(
          handleData: (AccelerometerEvent event, EventSink<AccelerometerEvent> sink) {
            sink.add(event); // Pass through the event
            // Delay the stream by 500 milliseconds
            Future.delayed(const Duration(milliseconds: 10000), () {
              sink.add(event);
            });
          },
        ),
      )
          .listen(
            (AccelerometerEvent event) {
          _updateOrientation(event); // Calculate the roll on new data
        },
      ),
    );
  }


  void _updateOrientation(AccelerometerEvent event) {
    // Calculating roll based on the accelerometer data
    double y = event.y;
    double z = event.z;

    _roll = atan2(y, z) * (180.0 / pi); // Convert radians to degrees

    // Trigger a build whenever new data is processed
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Sensor Data Display'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Roll (Y-axis): ${_roll?.toStringAsFixed(2)}°'), // Displaying the roll
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    // Canceling the stream subscription on dispose
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }
}