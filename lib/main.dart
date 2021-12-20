import 'package:flutter/material.dart';
import 'package:link_motion_tool/configuration_button_list.dart';
import 'package:link_motion_tool/pickup_software_location.dart';
import 'package:link_motion_tool/preference_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String softwarePath = await PreferenceService.getSoftwarePath();
  String softwareConfigPath = await PreferenceService.getSoftwareConfigPath();
  int configFileListCount =
      (await PreferenceService.getConfigurationFilePath()).length;
  runApp(LinkMotionToolApp(
      softwarePath: softwarePath,
      softwareConfigPath: softwareConfigPath,
      configFileListCount: configFileListCount));
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
      home: softwareConfigPath.isNotEmpty &&
              softwarePath.isNotEmpty &&
              configFileListCount > 0
          ? const ConfigurationButtonList()
          : const PickupSoftwareLocation(),
    );
  }
}
