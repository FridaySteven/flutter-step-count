import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_step_count/src/step_count_app/step_count_model.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepCountProvider extends ChangeNotifier {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;

  int steps = 0;
  DateTime timeStamp1 = DateTime.now();
  bool status = false;
  String statusTxt = '';
  DateTime timeStamp2 = DateTime.now();
  String dtFromat = 'yyyy-MM-dd hh:mm:ss a';

  void initState(BuildContext context) {
    flush();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      // ask for permission
      final permission = await _getMotionPermission();

      if (permission != null && context.mounted) {
        if (permission.isPermanentlyDenied) {
          Navigator.pop(context);
          await Future.delayed(const Duration(milliseconds: 500), () {});
          openAppSettings();
          return;
        } else if (!permission.isGranted) {
          Navigator.pop(context);
          return;
        }
      }
      checkRunningBackground();
      initPlatformState();
      // buildMinStepCount();
    });
  }

  Future<void> initPlatformState() async {
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
  void _onStepCount(StepCount event) {
    steps = event.steps;
    timeStamp1 = event.timeStamp;

    SharedPreferences.getInstance().then((preferences) async {
      await preferences.setString("Step_Count", "$steps");
    });

    buildPageLoadStepCount();
    buildHourStepCount();
    // TODO:: take note
    // it mike be some error if concurrently the step need to be calculate
    // instate we use timmer to keep track the step in every ...(time)
    if (firstStepCountMin) {
      buildMinStepCount();
    }

    debugPrint('szs ====> $steps, $displaySteps, $previousSteps');

    notifyListeners();
  }

  /// Handle status changed
  void _onPedestrianStatusChanged(PedestrianStatus event) {
    statusTxt = event.status;
    status = event.status == 'walking';

    timeStamp2 = event.timeStamp;

    debugPrint('szs ====::::::::::::::::::> $status');
    notifyListeners();
  }

  late Permission motionPermission;
  Future<PermissionStatus?> _getMotionPermission() async {
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

  /// Handle the error
  void onPedestrianStatusError(error) {
    debugPrint('Error onPedestrianStatusError: $error');
  }

  /// Handle the error
  void onStepCountError(error) {
    debugPrint('Error onStepCountError: $error');
  }

  // ==================== Below is additional function =====================

  //#region on page load count (start from 0 everytime page init)
  bool firstStepCount = false;
  int previousSteps = 0;
  int displaySteps = 0;
  String displayStepsDT = '';
  DateTime previousTimeStamp1 = DateTime.now();
  void buildPageLoadStepCount() {
    if (firstStepCount) {
      previousSteps = steps;
      previousTimeStamp1 = timeStamp1;
      displaySteps = steps - steps;
      firstStepCount = false;
    } else {
      displaySteps = steps - previousSteps;
    }
    displayStepsDT =
        'Start: ${DateFormat(dtFromat).format(previousTimeStamp1)}\n End: ${DateFormat(dtFromat).format(timeStamp1)}';
  }
  //#endregion on page load count (start from 0 everytime page init)

  //#region check every hour step count
  bool firstStepCountHour = false;
  List<StepCountPeriod> stepCountPreiodHourList = [];
  int displayStepCountHour = 0;
  void buildHourStepCount() {
    if (firstStepCountHour) {
      _hourStepCountChecking();
      firstStepCountHour = false;
    } else {
      _hourStepCountChecking();
    }
  }

  bool firstAddHourList = false;
  void _hourStepCountChecking() {
    if (stepCountPreiodHourList.isNotEmpty) {
      final lastSC = stepCountPreiodHourList.last.previousStepCount;

      // if (lastSC < steps) {
      //   stepCountPreiodHourList.last
      //     ..stepCountDateTime = timeStamp1
      //     ..stepCount = steps;
      // }

      final lastDT = stepCountPreiodHourList.last.stepCountDateTime;
      final lastHour = DateTime.now().difference(lastDT).inHours;

      int calStep = steps - lastSC;
      if (lastHour > 0) {
        stepCountPreiodHourList.add(StepCountPeriod(
          stepCountDateTime: timeStamp1,
          stepCount: calStep,
          displayStepCount: calStep,
          previousStepCount: steps,
        ));
        displayStepCountHour = calStep;
        firstAddHourList = false;
      } else {
        if (firstAddHourList) {
          calStep += stepCountPreiodHourList.last.stepCount;
        }
        displayStepCountHour = calStep;
        stepCountPreiodHourList.last.displayStepCount = displayStepCountHour;
      }
    } else {
      displayStepCountHour = steps;
      stepCountPreiodHourList.add(StepCountPeriod(
        stepCountDateTime: timeStamp1,
        stepCount: displayStepCountHour,
        displayStepCount: displayStepCountHour,
        previousStepCount: displayStepCountHour,
      ));
      firstAddHourList = true;
    }
  }
  //#endregion check every hour step count

  //#region check every minute step count
  bool firstStepCountMin = false;
  late Timer minTimer;
  List<StepCountPeriod> stepCountPreiodMinList = [];
  int displayStepCountMin = 0;
  void buildMinStepCount() {
    _minStepCountChecking();
    firstStepCountMin = false;

    minTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      debugPrint('szs ==-=-=-=-=-=-=-=-=- timer: $timer');
      _minStepCountChecking();
      notifyListeners();
    });
  }

  bool firstAddMinList = false;
  void _minStepCountChecking() {
    if (stepCountPreiodMinList.isNotEmpty) {
      final previousLastSC = stepCountPreiodMinList.last.previousStepCount;

      // if (lastSC < steps) {
      //   stepCountPreiodMinList.last
      //     ..stepCountDateTime = timeStamp1
      //     ..stepCount = steps;
      // }

      final lastDT = stepCountPreiodMinList.last.stepCountDateTime;
      final lastMin = DateTime.now().difference(lastDT).inMinutes;

      int calStep = steps - previousLastSC;
      if (lastMin > 0) {
        stepCountPreiodMinList.add(StepCountPeriod(
          stepCountDateTime: timeStamp1,
          stepCount: calStep,
          displayStepCount: calStep,
          previousStepCount: steps,
        ));
        displayStepCountMin = calStep;
        firstAddMinList = false;
      } else {
        if (firstAddMinList) {
          calStep += stepCountPreiodMinList.last.stepCount;
        }
        displayStepCountMin = calStep;
        stepCountPreiodMinList.last.displayStepCount = displayStepCountMin;
      }
    } else {
      displayStepCountMin = steps;
      stepCountPreiodMinList.add(StepCountPeriod(
        stepCountDateTime: timeStamp1,
        stepCount: displayStepCountMin,
        displayStepCount: displayStepCountMin,
        previousStepCount: displayStepCountMin,
      ));
      firstAddMinList = true;
    }
  }
  //#endregion check every minute step count

  void onDeactivate() {
    // stepCountPreiodHourList.clear();
    // stepCountPreiodMinList.clear();
    minTimer.cancel();
  }

  void flush() {
    firstStepCount = true;
    firstStepCountHour = true;
    firstStepCountMin = true;

    firstAddHourList = true;
    firstAddMinList = true;
  }

  var isRunningBG = false;
  Future<void> checkRunningBackground() async {
    final service = FlutterBackgroundService();
    isRunningBG = await service.isRunning();
    notifyListeners();
  }
}
