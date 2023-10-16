import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_step_count/src/step_count_app/step_count_provider.dart';
import 'package:provider/provider.dart';

class StepCountView extends StatefulWidget {
  const StepCountView({super.key});

  static const routeName = '/step_count_view';

  @override
  State<StepCountView> createState() => _StepCountViewState();
}

class _StepCountViewState extends State<StepCountView> {
  ExpandableController expController = ExpandableController();

  @override
  void initState() {
    super.initState();
    Provider.of<StepCountProvider>(context, listen: false).initState(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0x00000000),
        ),
        title: const Text('Step Count'),
        centerTitle: true,
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          TopBannerStepCountWidget(expController: expController),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text(
              'My Step in Every Hour',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 85,
            child: Consumer<StepCountProvider>(builder: (context, provider, _) {
              return ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                scrollDirection: Axis.horizontal,
                itemCount: provider.stepCountPreiodHourList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${provider.stepCountPreiodHourList[index].displayStepCount}',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Steps'),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text(
              'My Step in Every Minute',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 85,
            child: Consumer<StepCountProvider>(builder: (context, provider, _) {
              return ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                scrollDirection: Axis.horizontal,
                itemCount: provider.stepCountPreiodMinList.length,
                itemBuilder: (context, index) {
                  final reversedIdx =
                      provider.stepCountPreiodMinList.length - index - 1;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${provider.stepCountPreiodMinList[reversedIdx].displayStepCount}',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Steps'),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          ListView.builder(
            itemCount: 30,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) => Container(
              margin: const EdgeInsets.all(10),
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TopBannerStepCountWidget extends StatefulWidget {
  const TopBannerStepCountWidget({
    super.key,
    required this.expController,
  });

  final ExpandableController expController;

  @override
  State<TopBannerStepCountWidget> createState() =>
      _TopBannerStepCountWidgetState();
}

class _TopBannerStepCountWidgetState extends State<TopBannerStepCountWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<StepCountProvider>(builder: (context, provider, _) {
      return Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.black,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Transform.scale(
                        origin: const Offset(0, 100),
                        alignment: Alignment.centerLeft,
                        transformHitTests: false,
                        scale: 1,
                        child: Text(
                          '${provider.steps}',
                          softWrap: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    const Text(
                      'Daily/Step(s)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        height: 6.3,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white),
                ExpandableNotifier(
                  controller: widget.expController,
                  child: Expandable(
                    collapsed: InkWell(
                      onTap: widget.expController.toggle,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Daily Goal: 5000',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            Icons.expand_more,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                    expanded: InkWell(
                      onTap: widget.expController.toggle,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      right: 10, top: 10, bottom: 10),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.white),
                                    color: Colors.black,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.directions_run_rounded,
                                            color: Colors.white,
                                            size: 45,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'My Goal',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            '5000',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.directions_walk_rounded,
                                            color: Colors.white,
                                            size: 45,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Extra Walk',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            '500',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.nordic_walking_rounded,
                                            color: Colors.white,
                                            size: 45,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Monthly',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            '100k',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.expand_less,
                                color: Colors.white,
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Run step count app background? ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    Switch(
                                      value: provider.isRunningBG,
                                      activeColor: Colors.white,
                                      inactiveTrackColor: Colors.grey,
                                      onChanged: (val) async {
                                        final service =
                                            FlutterBackgroundService();
                                        var isRunning =
                                            await service.isRunning();
                                        if (isRunning) {
                                          service.invoke("stopService");
                                        } else {
                                          service.startService();
                                        }
                                        await Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {});
                                        provider.checkRunningBackground();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.expand_less,
                                color: Colors.transparent,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 3,
              right: 3,
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: provider.status ? Colors.lightGreen : Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: provider.status
                          ? Colors.lightGreen.withOpacity(0.8)
                          : Colors.red.withOpacity(0.8),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
