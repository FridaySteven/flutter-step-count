import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_step_count/src/provider/step_count_provider.dart';
import 'package:provider/provider.dart';

/// Displays detailed information about a SampleItem.
class SampleItemDetailsView extends StatefulWidget {
  const SampleItemDetailsView({super.key});

  static const routeName = '/sample_item';

  @override
  State<SampleItemDetailsView> createState() => _SampleItemDetailsViewState();
}

class _SampleItemDetailsViewState extends State<SampleItemDetailsView> {
  @override
  void initState() {
    super.initState();
    Provider.of<StepCountProvider>(context, listen: false).initState(context);
  }

  @override
  void deactivate() {
    super.deactivate();
    Provider.of<StepCountProvider>(context, listen: false).onDeactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StepCountProvider>(builder: (context, provider, _) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Step Count'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            _stepCountCard(
              'Total count (starting form root when app first install) and restart phone to recount (start from 0)',
              walkStatus: provider.status,
              displaySteps: provider.steps,
            ),
            _stepCountCard(
              'Total count (Start from 0 on page start)',
              walkStatus: provider.status,
              displaySteps: provider.displaySteps,
              startEndDTText: provider.displayStepsDT,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _stepCountCard(
                  'Total count (by hour)',
                  walkStatus: provider.status,
                  displaySteps: provider.displayStepCountHour,
                  // startEndDTText: provider.displayStepsDT,
                ),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.stepCountPreiodHourList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${provider.stepCountPreiodHourList[index].displayStepCount}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Steps',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _stepCountCard(
                  'Total count (by minute)',
                  walkStatus: provider.status,
                  displaySteps: provider.displayStepCountMin,
                  // startEndDTText: provider.displayStepsDT,
                ),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.stepCountPreiodMinList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${provider.stepCountPreiodMinList[index].displayStepCount}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Steps',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
            ElevatedButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: const Text(
                  'Keep step conter working, but want to get out from app? Click Me'),
            )
          ],
        ),
      );
    });
  }

  Column _stepCountCard(
    String title, {
    String walkStatus = 'stopped',
    int displaySteps = 0,
    String? startEndDTText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Card(
          color: const Color.fromARGB(255, 0, 255, 234),
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _stepCountRow(walkStatus, displaySteps),
                if (startEndDTText != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        startEndDTText,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }

  Row _stepCountRow(String walkStatus, int displaySteps) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(
          Icons.directions_walk_rounded,
          size: 80,
          color: walkStatus == 'walking' ? Colors.green : Colors.red,
        ),
        Text(
          '$displaySteps',
          style: const TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black, // Choose the color of the shadow
                blurRadius: 15, // Adjust the blur radius for the shadow effect
                offset: Offset(-2,
                    -2), // Set the horizontal and vertical offset for the shadow
              ),
            ],
          ),
        ),
        const Text(
          'Total/Step(s)',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Center test(StepCountProvider provider) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 100),
          Text('My Step: ${provider.steps}'),
          const SizedBox(height: 100),
          Text('My Step: ${provider.status}'),
          const SizedBox(height: 100),
          Text('Time Stamp: ${provider.timeStamp1}'),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
