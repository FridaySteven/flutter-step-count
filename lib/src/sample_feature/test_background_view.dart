import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestBackground extends StatefulWidget {
  const TestBackground({Key? key}) : super(key: key);

  static const routeName = '/test_background';

  @override
  State<TestBackground> createState() => _TestBackgroundState();
}

class _TestBackgroundState extends State<TestBackground> {
  String text = "Stop Service";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service App'),
      ),
      body: Center(
        child: Column(
          children: [
            StreamBuilder<Map<String, dynamic>?>(
              stream: FlutterBackgroundService().on('update'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final data = snapshot.data!;
                String? device = data["device"];
                DateTime? date = DateTime.tryParse(data["current_date"]);
                return Column(
                  children: [
                    Text(device ?? 'Unknown'),
                    Text(date.toString()),
                  ],
                );
              },
            ),
            ElevatedButton(
              child: const Text("Foreground Mode \n IOS not support"),
              onPressed: () {
                FlutterBackgroundService().invoke("setAsForeground");
              },
            ),
            ElevatedButton(
              child: const Text("Background Mode \n IOS not support"),
              onPressed: () {
                FlutterBackgroundService().invoke("setAsBackground");
              },
            ),
            ElevatedButton(
              child: Text(text),
              onPressed: () async {
                final service = FlutterBackgroundService();
                var isRunning = await service.isRunning();
                if (isRunning) {
                  service.invoke("stopService");
                } else {
                  service.startService();
                }

                if (!isRunning) {
                  text = 'Stop Service';
                } else {
                  text = 'Start Service';
                }
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LogView extends StatefulWidget {
  const LogView({Key? key}) : super(key: key);

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final Timer timer;
  List<String> logs = [];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.reload();
      logs = sp.getStringList('log') ?? [];
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber,
      child: Column(
        children: [
          Text('${logs.length}'),
          ListView.builder(
            shrinkWrap: true,
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs.elementAt(index);
              return Text(log);
            },
          ),
        ],
      ),
    );
  }
}
