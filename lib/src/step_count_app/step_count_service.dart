import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class StepCountService {
  static late Permission motionPermission;
  static Future<PermissionStatus?> getMotionPermission() async {
    if (Platform.isAndroid) {
      motionPermission = Permission.activityRecognition;
    } else {
      motionPermission = Permission.sensors;
    }

    if (!await motionPermission.isGranted) {
      return await motionPermission.request();
    }
    return PermissionStatus.granted;
  }

  static late Stream<StepCount> _stepCountStream;
  static late Stream<PedestrianStatus> _pedestrianStatusStream;

  static int steps = 0;
  static DateTime timeStamp1 = DateTime.now();
  static bool status = false;
  static DateTime timeStamp2 = DateTime.now();
  static String dtFromat = 'yyyy-MM-dd hh:mm:ss a';

  static Future<void> initPlatformState() async {
    // Init streams
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _stepCountStream = Pedometer.stepCountStream;

    // Listen to streams and handle errors
    _stepCountStream.listen(_onStepCount).onError(onStepCountError);

    _pedestrianStatusStream
        .listen(_onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);
  }

  /// Handle step count changed
  static void _onStepCount(StepCount event) {
    steps = event.steps;
    timeStamp1 = event.timeStamp;

    debugPrint('szs ==service==::::::::::::::::::> $steps');
  }

  /// Handle status changed
  static void _onPedestrianStatusChanged(PedestrianStatus event) {
    if (event.status == 'walking') {
      status = true;
    } else {
      status = false;
    }

    timeStamp2 = event.timeStamp;

    debugPrint('szs ====::::::::::::::::::> $status');
  }

  /// Handle the error
  static void onPedestrianStatusError(error) {
    debugPrint('Error onPedestrianStatusError: $error');
  }

  /// Handle the error
  static void onStepCountError(error) {
    debugPrint('Error onStepCountError: $error');
  }

  static int getStep() {
    return steps;
  }
}
