import 'package:flutter/material.dart';
import 'package:flutter_step_count/src/sample_feature/sample_item_details_view.dart';
import 'package:flutter_step_count/src/sample_feature/sample_item_list_view.dart';
import 'package:flutter_step_count/src/service/flutter_background_service.dart';
import 'package:flutter_step_count/src/settings/settings_controller.dart';
import 'package:flutter_step_count/src/settings/settings_view.dart';
import 'package:flutter_step_count/src/step_count_app/step_count_provider.dart';
import 'package:flutter_step_count/src/step_count_app/step_count_view.dart';
import 'package:provider/provider.dart';

Route<dynamic> generateRoute(
    RouteSettings routeSettings, SettingsController settingsController) {
  return MaterialPageRoute<void>(
    settings: routeSettings,
    builder: (BuildContext context) {
      switch (routeSettings.name) {
        case SettingsView.routeName:
          return SettingsView(controller: settingsController);
        case SampleItemDetailsView.routeName:
          return const SampleItemDetailsView();
        case TestBackground.routeName:
          return const TestBackground();
        case StepCountView.routeName:
          return MultiProvider(providers: [
            ChangeNotifierProvider<StepCountProvider>(
              create: (context) => StepCountProvider(),
            ),
          ], child: const StepCountView());
        default:
          return const SampleItemListView();
      }
    },
  );
}
