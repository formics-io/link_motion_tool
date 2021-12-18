import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:link_motion_tool/form_field_widget.dart';
import 'package:link_motion_tool/preference_service.dart';
import 'dart:io' as io;

class PickupSoftwareLocation extends StatefulWidget {
  final String softwarePath;
  final String softwareConfigPath;
  const PickupSoftwareLocation(
      {Key? key, required this.softwarePath, required this.softwareConfigPath})
      : super(key: key);

  @override
  _PickupSoftwareLocationState createState() => _PickupSoftwareLocationState();
}

class _PickupSoftwareLocationState extends State<PickupSoftwareLocation> {
  late TextEditingController _softwarePathController;
  late TextEditingController _softwareConfigPathController;
  late bool disableSoftwarePicker;
  late bool disableSoftwareConfigPicker;
  late List<CustomTextFormField> textFormFieldList;
  late int selectedConfigIndex;
  late ScrollController _scrollController;

  @override
  void initState() {
    _softwarePathController = TextEditingController();
    _softwarePathController.text = widget.softwarePath;
    _softwareConfigPathController = TextEditingController();
    _softwareConfigPathController.text = widget.softwareConfigPath;
    textFormFieldList = List<CustomTextFormField>.empty(growable: true);
    disableSoftwarePicker = false;
    disableSoftwareConfigPicker = false;
    selectedConfigIndex = -1;
    _scrollController = ScrollController();
    getFormFields();
    super.initState();
  }

  validatePaths() async {
    String softwarePath = await PreferenceService.getSoftwarePath();
    String softwareConfigPath = await PreferenceService.getSoftwareConfigPath();
    String replacementConfigFile =
        textFormFieldList.isNotEmpty && selectedConfigIndex > -1
            ? textFormFieldList[selectedConfigIndex].path
            : '';
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
          showSnackBar("Select configuration file to replace");
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
  }

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 5),
    ));
  }

  Future<void> getFormFields() async {
    List<CustomTextFormField> textFieldList =
        (await PreferenceService.getConfigurationFilePath())
            .asMap()
            .entries
            .map((e) => CustomTextFormField(
                  path: e.value,
                ))
            .toList();
    if (textFieldList.isNotEmpty) {
      setState(() {
        textFormFieldList.addAll(textFieldList);
      });
    }
  }

  void onConfigChange(int index) {
    setState(() {
      selectedConfigIndex = index;
    });
  }

  Container configFileList(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      margin: const EdgeInsets.all(20),
      decoration:
          BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
      child: Scrollbar(
        controller: _scrollController,
        isAlwaysShown: true,
        child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (lctx, index) {
              return configFilePickupWidget(index);
            },
            itemCount: textFormFieldList.length),
      ),
    );
  }

  Container configFilePickupWidget(int index) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Flexible(
            flex: 0,
            child: IconButton(
                tooltip: "Select configuration",
                onPressed: () => onConfigChange(index),
                icon: Icon(selectedConfigIndex == index
                    ? Icons.radio_button_on_outlined
                    : Icons.radio_button_off_outlined)),
          ),
          Flexible(flex: 1, child: textFormFieldList[index]),
          Flexible(
              flex: 0,
              child: IconButton(
                  tooltip: "Delete configuration",
                  onPressed: () => removeConfigurationPath(index),
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  )))
        ],
      ),
    );
  }

  Container softwareConfigPathPickupWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: TextFormField(
              readOnly: true,
              onTap: () => pickupConfigurationFile(false),
              controller: _softwareConfigPathController,
              enabled: !disableSoftwareConfigPicker,
              decoration: const InputDecoration(
                label: Text("Select software config path"),
                contentPadding: EdgeInsets.all(20),
                suffixIcon: Icon(Icons.app_settings_alt_outlined),
                hintText: "Select software config path",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          TextButton(
              onPressed: () {
                setState(() {
                  disableSoftwareConfigPicker = false;
                  pickupConfigurationFile(false);
                });
              },
              child: const Text(
                "Change",
                style: TextStyle(decoration: TextDecoration.underline),
              ))
        ],
      ),
    );
  }

  Container softwarePathPickupWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: TextFormField(
              readOnly: true,
              onTap: () => pickupSoftwareFile(),
              controller: _softwarePathController,
              enabled: !disableSoftwarePicker,
              decoration: const InputDecoration(
                label: Text("Select software path"),
                contentPadding: EdgeInsets.all(20),
                suffixIcon: Icon(Icons.app_settings_alt_outlined),
                hintText: "Select software path",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          TextButton(
              onPressed: () {
                setState(() {
                  disableSoftwarePicker = false;
                  pickupSoftwareFile();
                });
              },
              child: const Text(
                "Change",
                style: TextStyle(decoration: TextDecoration.underline),
              ))
        ],
      ),
    );
  }

  pickupSoftwareFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ["exe"]);
    if (result != null) {
      setState(() {
        _softwarePathController.text = result.files.single.path ?? '';
        disableSoftwarePicker = true;
        PreferenceService.setSoftwarePath(_softwarePathController.text);
      });
    } else {
      debugPrint("No file selected");
    }
  }

  pickupConfigurationFile(bool isCustomConfig) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ["ini"]);
    if (result != null && result.files.single.path!.isNotEmpty) {
      if (isCustomConfig) {
        setState(() {
          PreferenceService.addConfigurationFilePath(
              result.files.single.path ?? '');
          textFormFieldList.add(CustomTextFormField(
            path: result.files.single.path ?? '',
          ));
        });
      } else {
        _softwareConfigPathController.text = result.files.single.path ?? '';
        disableSoftwareConfigPicker = true;
        PreferenceService.setSoftwareConfigPath(
            _softwareConfigPathController.text);
      }
    } else {
      debugPrint("No file selected");
    }
  }

  removeConfigurationPath(int index) {
    setState(() {
      textFormFieldList.removeAt(index);
    });
    PreferenceService.deleteConfigurationFilePath(index);
    if (textFormFieldList.isEmpty || selectedConfigIndex == index) {
      setState(() {
        selectedConfigIndex = -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            softwarePathPickupWidget(),
            softwareConfigPathPickupWidget(),
            configFileList(context),
            OutlinedButton(
              style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.all(40)),
                  backgroundColor: MaterialStateProperty.all(Colors.blue)),
              child: const Text(
                "Run App",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: validatePaths,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add new configuration",
        onPressed: () => pickupConfigurationFile(true),
        child: const Icon(Icons.add),
      ),
    );
  }
}
