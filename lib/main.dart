import 'package:flutter/material.dart';
import 'package:link_motion_tool/pickup_software_location.dart';
import 'package:link_motion_tool/preference_service.dart';

void main() async {
  String softwarePath = await PreferenceService.getSoftwarePath();
  String softwareConfigPath = await PreferenceService.getSoftwareConfigPath();
  runApp(LinkMotionToolApp(
    softwarePath: softwarePath,
    softwareConfigPath: softwareConfigPath,
  ));
}

class LinkMotionToolApp extends StatelessWidget {
  final String softwarePath;
  final String softwareConfigPath;
  const LinkMotionToolApp(
      {Key? key, required this.softwarePath, required this.softwareConfigPath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PickupSoftwareLocation(
        softwarePath: softwarePath,
        softwareConfigPath: softwareConfigPath,
      ),
    );
  }
}
