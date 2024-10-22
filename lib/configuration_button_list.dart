import 'dart:io';

import 'package:flutter/material.dart';
import 'package:link_motion_tool/bouncing_button.dart';
import 'package:link_motion_tool/config_file_model.dart';
import 'package:link_motion_tool/pickup_software_location.dart';
import 'package:link_motion_tool/preference_service.dart';
import 'dart:io' as io;


class ConfigurationButtonList extends StatefulWidget {
  const ConfigurationButtonList({Key? key}) : super(key: key);

  @override
  _ConfigurationButtonListState createState() =>
      _ConfigurationButtonListState();
}

class _ConfigurationButtonListState extends State<ConfigurationButtonList> {
  Future<List<ConfigFileModel>> getConfigFileList() async {
    return await PreferenceService.getConfigurationFilePath();
  }

  validatePaths(String configPath) async {
    String softwarePath = await PreferenceService.getSoftwarePath();
    String softwareConfigPath = await PreferenceService.getSoftwareConfigPath();
    String replacementConfigFile = configPath;
    if (softwarePath.isNotEmpty) {
      if (softwareConfigPath.isNotEmpty) {
        if (replacementConfigFile.isNotEmpty) {
          String softwareFolderPath =
              (softwarePath.split('\\')..removeLast()).join('\\').toString();
          executeConfigCommand(
              softwareFolderPath,
              softwarePath.split('\\').removeLast(),
              replacementConfigFile,
              softwareConfigPath);
        } else {
          showSnackBar("Add configuration file to replace");
        }
      } else {
        showSnackBar("Select software config path first");
      }
    } else {
      showSnackBar("Select software path first");
    }
  }

  executeConfigCommand(String softwareFolderPath, String softwareFilePath,
      String sourceConfigFilePath, String destinationConfigFilePath) async {
    await io.Process.run("Taskkill", ["/IM", softwareFilePath, "/F"],
        runInShell: true);
    await io.Process.run(
        "copy", [sourceConfigFilePath, destinationConfigFilePath],
        runInShell: true);
    io.Process.run("start", [softwareFilePath],
        runInShell: true, workingDirectory: softwareFolderPath);
    showSnackBar("Application launched");
    io.Process.run("Taskkill", ["/IM", 'link_motion_tool.exe', "/F"],
        runInShell: true);
  }

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 5),
    ));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    return Scaffold(
      appBar: AppBar(
        title: const Text("SMA_MODE_MASTER"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => const PickupSoftwareLocation()));
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: FutureBuilder<List<ConfigFileModel>>(
        future: getConfigFileList(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 2,
                //mainAxisExtent: 100,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                crossAxisCount: 2),
              itemCount: snapshot.data!.length,
              padding: const EdgeInsets.all(20),
              itemBuilder: (ctx, index) {
                final configFile = snapshot.data![index];
                double height =  double.parse(configFile.height!.isEmpty? '40' : configFile.height!);
                double width = double.parse(configFile.width!.isEmpty? '60' : configFile.width!);
                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate dynamic width and height based on screen size or container constraints
                    double dynamicHeight = constraints.maxHeight * (height*.009);
                    double dynamicWidth = constraints.maxWidth * (width*.01);
                    return Container(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: dynamicWidth,
                            height: dynamicHeight,
                            child: BouncingButton(
                              color: getColorFromName(configFile.color!),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Image.file(
                                  File(configFile.imagePath!),
                                  height: dynamicHeight,
                                  width: dynamicWidth,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              onPressed: () => validatePaths(configFile.path),
                            ),
                          ),
                          const SizedBox(height: 8), // Space between button and text
                          Text(
                            configFile.name,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: dynamicWidth * 0.1, // Adjust font size relative to button width
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}


Color getColorFromName(String colorName) {
  switch (colorName.toLowerCase()) {
    case 'red':
      return Colors.red;
    case 'green':
      return Colors.green;
    case 'blue':
      return Colors.blue;
    case 'yellow':
      return Colors.yellow;
    case 'orange':
      return Colors.orange;
    case 'purple':
      return Colors.purple;
    case 'black':
      return Colors.black;
    case 'white':
      return Colors.white;
    case 'grey':
      return Colors.grey;
    case 'pink':
      return Colors.pink;
    case 'brown':
      return Colors.brown;
    default:
      return Colors.green; // Default case if no color matches
  }
}