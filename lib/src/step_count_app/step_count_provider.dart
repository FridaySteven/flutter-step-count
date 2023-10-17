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
  final storeStepList = <StepCountModel>[];

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

    storeStepList.add(StepCountModel(dateTime: timeStamp1, steps: steps));

    SharedPreferences.getInstance().then((preferences) async {
      await preferences.setString("Step_Count", "$steps");
    });

    buildPageLoadStepCount();
    buildHourStepCount();
    buildMinStepCount();

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
  bool loadingHour = false;
  bool firstStepCountHour = false;
  List<StepCountPeriod> stepCountPreiodHourList = [];
  int displayStepCountHour = 0;
  void buildHourStepCount({bool refresh = false}) {
    // Auto refresh
    if (!refresh) {
      _hourStepCountChecking(
        steps,
        timeStamp1,
        checkTime: DateTime.now(),
      );
      return;
    }

    loadingHour = true;
    notifyListeners();
    stepCountPreiodHourList.clear();
    firstAddHourList = true;

    for (StepCountModel storeStep in storeStepList) {
      _hourStepCountChecking(
        storeStep.steps,
        storeStep.dateTime,
        checkTime: storeStep.dateTime,
      );
    }

    Future.delayed(const Duration(milliseconds: 1000), () {
      loadingHour = false;
      notifyListeners();
    });
  }

  bool firstAddHourList = false;
  void _hourStepCountChecking(
    int currentSteps,
    DateTime currentTimeStamp, {
    required DateTime checkTime,
  }) {
    if (stepCountPreiodHourList.isNotEmpty) {
      final lastStepDetails = stepCountPreiodHourList.last;
      final passFirstStep = lastStepDetails.passEveryFirstSteps;
      final lastDT = lastStepDetails.dateTime;
      final overHour = checkTime.difference(lastDT).inHours;

      int calStep = currentSteps - passFirstStep;
      if (overHour > 0) {
        final remainingSteps = currentSteps - lastStepDetails.previousSteps;
        stepCountPreiodHourList.add(StepCountPeriod(
          dateTime: currentTimeStamp,
          keepTrackFirstCount: calStep,
          displaySteps: calStep + remainingSteps,
          passEveryFirstSteps: currentSteps - remainingSteps,
          previousSteps: currentSteps,
        ));
        displayStepCountHour = calStep;
        firstAddHourList = false;
      } else {
        if (firstAddHourList) {
          calStep += lastStepDetails.keepTrackFirstCount;
        }

        displayStepCountHour = calStep;
        lastStepDetails
          ..previousSteps = currentSteps
          ..displaySteps = displayStepCountHour;
      }
    } else {
      displayStepCountHour = currentSteps;
      stepCountPreiodHourList.add(StepCountPeriod(
        dateTime: currentTimeStamp,
        keepTrackFirstCount: displayStepCountHour,
        displaySteps: displayStepCountHour,
        passEveryFirstSteps: displayStepCountHour,
        previousSteps: displayStepCountHour,
      ));
    }
  }
  //#endregion check every hour step count

  //#region check every minute step count
  bool loadingMin = false;
  bool firstStepCountMin = false;
  List<StepCountPeriod> stepCountPreiodMinList = [];
  int displayStepCountMin = 0;
  void buildMinStepCount({bool refresh = false}) {
    // Auto refresh
    if (!refresh) {
      _minStepCountChecking(
        steps,
        timeStamp1,
        checkTime: DateTime.now(),
      );
      return;
    }
    loadingMin = true;
    notifyListeners();
    stepCountPreiodMinList.clear();
    firstAddMinList = true;

    for (StepCountModel storeStep in storeStepList) {
      _minStepCountChecking(
        storeStep.steps,
        storeStep.dateTime,
        checkTime: storeStep.dateTime,
      );
    }

    Future.delayed(const Duration(milliseconds: 1000), () {
      loadingMin = false;
      notifyListeners();
    });
  }

  bool firstAddMinList = false;
  Future<void> _minStepCountChecking(
    int currentSteps,
    DateTime currentTimeStamp, {
    required DateTime checkTime,
  }) async {
    if (stepCountPreiodMinList.isNotEmpty) {
      final lastStepDetails = stepCountPreiodMinList.last;
      final passFirstStep = lastStepDetails.passEveryFirstSteps;
      final lastDT = lastStepDetails.dateTime;
      final overMin = checkTime.difference(lastDT).inMinutes;

      int calStep = currentSteps - passFirstStep;
      if (overMin > 0) {
        final remainingSteps = currentSteps - lastStepDetails.previousSteps;
        debugPrint('szsdebug :::: $remainingSteps');
        stepCountPreiodMinList.add(StepCountPeriod(
          dateTime: currentTimeStamp,
          keepTrackFirstCount: calStep,
          displaySteps: calStep + remainingSteps,
          passEveryFirstSteps: currentSteps - remainingSteps,
          previousSteps: currentSteps,
        ));
        displayStepCountMin = calStep;
        firstAddMinList = false;
      } else {
        if (firstAddMinList) {
          calStep += lastStepDetails.keepTrackFirstCount;
        }

        displayStepCountMin = calStep;
        lastStepDetails
          ..previousSteps = currentSteps
          ..displaySteps = displayStepCountMin;
      }
    } else {
      displayStepCountMin = currentSteps;
      stepCountPreiodMinList.add(StepCountPeriod(
        dateTime: currentTimeStamp,
        keepTrackFirstCount: displayStepCountMin,
        displaySteps: displayStepCountMin,
        passEveryFirstSteps: displayStepCountMin,
        previousSteps: displayStepCountMin,
      ));
    }
  }
  //#endregion check every minute step count

  void onDeactivate() {
    // stepCountPreiodHourList.clear();
    // stepCountPreiodMinList.clear();
  }

  void flush() {
    firstStepCount = true;
    firstStepCountHour = true;
    firstStepCountMin = true;

    firstAddHourList = true;
    firstAddMinList = true;

    storeStepList.clear();
  }

  var isRunningBG = false;
  Future<void> checkRunningBackground() async {
    final service = FlutterBackgroundService();
    isRunningBG = await service.isRunning();
    notifyListeners();
  }
}
