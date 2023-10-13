class StepCountPeriod {
  StepCountPeriod({
    required this.stepCountDateTime,
    required this.stepCount,
    required this.displayStepCount,
    required this.previousStepCount,
  });

  DateTime stepCountDateTime;
  int stepCount;
  int displayStepCount;
  int previousStepCount;
}
