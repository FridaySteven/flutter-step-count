# Step Count App

## Description:
Step count app is help to count your total movement instate of your real foot step. The count will be star when the app start and movement permission granted. The count will be continuesly count until user restart their mobile phone, then the count will be start from 0. This app is supporting app back running, but user need to first start the app and grant mendetory permissions. ...

## File structure:
main
src
 |_ app
 |_ router
 |_ step_count_app
     |_ step_count_view
     |_ step_count_provider
     |_ step_count_model

*** *You can add new file like service file inside it when you needed.*

## Flutter version
Flutter 3.13.6 • channel stable
Tools • Dart 3.1.3 • DevTools 2.25.0

## Package needed
[pedometer](https://pub.dev/packages/pedometer) (Help to get the step count, status from Android and IOS platform)
[permission_handler](https://pub.dev/packages/permission_handler) (Help to get the permission from both Android and IOS platform)

*** *Additional setting/config needed to successfuly use the pedometer package - refer link above for all required setting/config*

## Code example on how to call/use step count package
<pre>

  void initState(BuildContext context) {

    // 'SchedulerBinding' is not required
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      // Ask/get for permission
      final permission = await _getMotionPermission();

      /// Check permission had been granted or not and do something
      /// Below is `FORCE` to get motion permision in status (granted)
      /// other then that will be pop out form screen
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

      // After get permission then init platform listener
      initPlatformState();
    });
  }

  Future<void> initPlatformState() async {
    // Init streams
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _stepCountStream = Pedometer.stepCountStream;

    // (step count) Listen to streams and handle errors 
    _stepCountStream.listen(_onStepCount).onError(onStepCountError);

    // (status) Listen to streams and handle errors 
    _pedestrianStatusStream
        .listen(_onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);
  }

  /// Handle step count changed
  void _onStepCount(StepCount event) {
    steps = event.steps;
    timeStamp1 = event.timeStamp;

    /// Add your code here, if you wish to do something when step change:
    /// create and call method to do something
    /// Exp: buildHourStepCount();

  }

  /// Handle status changed
  void _onPedestrianStatusChanged(PedestrianStatus event) {
    statusTxt = event.status;
    timeStamp2 = event.timeStamp;
  }

  // Help check motion permission had been granted or not
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

</pre>