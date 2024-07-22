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
        title: const Text("Link Motion Tool"),
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
                childAspectRatio: 3,
                //mainAxisExtent: 100,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                crossAxisCount: 2,
              ),
              itemCount: snapshot.data!.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (ctx, index) {
                final configFile = snapshot.data![index];
                double height =  double.parse(configFile.height!.isEmpty? '40' : configFile.height!);
                double width = double.parse(configFile.width!.isEmpty? '60' : configFile.width!);
                return Container(
                  margin: EdgeInsetsDirectional.symmetric(horizontal: width, vertical: height),
                  height: height,
                  width: width,
                  child: BouncingButton(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.file(File(configFile.imagePath!),),
                        const SizedBox(
                          width:30,
                        ),
                        Text(
                          configFile.name, 
                          style: const TextStyle(color: Colors.white, fontSize: 30), //itemHeight * 0.10),
                        ),
                      ],
                    ),
                    onPressed: () => validatePaths(configFile.path),
                  ),
                );
              },
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
