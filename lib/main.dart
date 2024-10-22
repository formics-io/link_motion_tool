import 'dart:async';
import 'package:flutter/material.dart';
import 'package:link_motion_tool/configuration_button_list.dart';
import 'package:link_motion_tool/pickup_software_location.dart';
import 'package:link_motion_tool/preference_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeWindow();

  String softwarePath = await PreferenceService.getSoftwarePath();
  String softwareConfigPath = await PreferenceService.getSoftwareConfigPath();
  int configFileListCount = (await PreferenceService.getConfigurationFilePath()).length;

  runApp(LinkMotionToolApp(
    softwarePath: softwarePath,
    softwareConfigPath: softwareConfigPath,
    configFileListCount: configFileListCount,
  ));
}

class LinkMotionToolApp extends StatelessWidget {
  final String softwarePath;
  final String softwareConfigPath;
  final int configFileListCount;

  const LinkMotionToolApp(
      {Key? key,
      required this.softwarePath,
      required this.softwareConfigPath,
      required this.configFileListCount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: softwareConfigPath.isNotEmpty &&
              softwarePath.isNotEmpty &&
              configFileListCount > 0
          ? const ConfigurationButtonList()
          : const PickupSoftwareLocation(),
    );
  }
}


Future<void> initializeWindow() async {
  final prefs = await SharedPreferences.getInstance();
  final window = appWindow;

  // Load saved size and position
  final width = prefs.getDouble('window_width') ?? 780.0;
  final height = prefs.getDouble('window_height') ?? 750.0;
  final x = prefs.getDouble('window_x') ?? 100.0;
  final y = prefs.getDouble('window_y') ?? 100.0;

  // Initialize window settings
  doWhenWindowReady(() {
    window.size = Size(width, height);
    window.position = Offset(x, y);
    window.minSize = const Size(640.0, 530.0);  // Set minimum size if desired
    window.maxSize = const Size(1925.0, 1002.0); // Set maximum size if desired
    window.show();
  });

  // Periodically save window state
  Timer.periodic(const Duration(seconds: 1), (_) async {
    final size = window.size;
    final position = window.position;

    await prefs.setDouble('window_width', size.width);
    await prefs.setDouble('window_height', size.height);
    await prefs.setDouble('window_x', position.dx);
    await prefs.setDouble('window_y', position.dy);
  });
}