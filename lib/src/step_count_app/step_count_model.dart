class StepCountModel {
  StepCountModel({
    required this.dateTime,
    required this.steps,
  });

  DateTime dateTime;
  int steps;
}

class StepCountPeriod {
  StepCountPeriod({
    required this.dateTime,
    required this.keepTrackFirstCount,
    required this.displaySteps,
    required this.passEveryFirstSteps,
    required this.previousSteps,
  });

  DateTime dateTime;
  int keepTrackFirstCount;
  int displaySteps;
  int passEveryFirstSteps;
  int previousSteps;
}
