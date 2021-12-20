import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:link_motion_tool/bouncing_button.dart';
import 'package:link_motion_tool/config_file_model.dart';
import 'package:link_motion_tool/configuration_button_list.dart';
import 'package:link_motion_tool/form_field_widget.dart';
import 'package:link_motion_tool/preference_service.dart';

class PickupSoftwareLocation extends StatefulWidget {
  const PickupSoftwareLocation({Key? key}) : super(key: key);

  @override
  _PickupSoftwareLocationState createState() => _PickupSoftwareLocationState();
}

class _PickupSoftwareLocationState extends State<PickupSoftwareLocation> {
  late TextEditingController _softwarePathController;
  late TextEditingController _softwareConfigPathController;
  late TextEditingController _customConfigPathController;
  late bool disableSoftwarePicker;
  late bool disableSoftwareConfigPicker;
  late List<CustomTextFormField> textFormFieldList;
  late int selectedConfigIndex;
  late ScrollController _scrollController;

  @override
  void initState() {
    _softwarePathController = TextEditingController();
    _softwareConfigPathController = TextEditingController();
    _customConfigPathController = TextEditingController();
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
    int replacementConfigFile =
        (await PreferenceService.getConfigurationFilePath()).length;
    if (softwarePath.isNotEmpty) {
      if (softwareConfigPath.isNotEmpty) {
        if (replacementConfigFile > 0) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext ctx) =>
                      const ConfigurationButtonList()),
              (route) => false);
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

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 5),
    ));
  }

  Future<void> getFormFields() async {
    String softwarePath = await PreferenceService.getSoftwarePath();
    String softwareConfigPath = await PreferenceService.getSoftwareConfigPath();
    _softwarePathController.text = softwarePath;
    _softwareConfigPathController.text = softwareConfigPath;
    List<CustomTextFormField> textFieldList =
        (await PreferenceService.getConfigurationFilePath())
            .asMap()
            .entries
            .map((e) => CustomTextFormField(
                  path: e.value.path,
                  name: e.value.name,
                ))
            .toList();
    if (textFieldList.isNotEmpty) {
      setState(() {
        textFormFieldList.addAll(textFieldList);
      });
    }
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
        String configName = await nameDialog();
        if (configName.isNotEmpty) {
          setState(() {
            PreferenceService.addConfigurationFilePath(ConfigFileModel(
                path: result.files.single.path ?? '', name: configName));
            textFormFieldList.add(CustomTextFormField(
              path: result.files.single.path ?? '',
              name: configName,
            ));
          });
        }
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

  nameDialog() async {
    return await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) {
          return AlertDialog(
            content: TextFormField(
              controller: _customConfigPathController,
              decoration: const InputDecoration(
                label: Text("Configuration name"),
                contentPadding: EdgeInsets.all(20),
                hintText: "Enter configuration name",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop('');
                  },
                  child: const Text("Cancel")),
              ElevatedButton(
                  onPressed: () {
                    if (_customConfigPathController.text.isNotEmpty) {
                      Navigator.of(context)
                          .pop(_customConfigPathController.text);
                      _customConfigPathController.clear();
                    } else {
                      showSnackBar("Please enter file name.");
                    }
                  },
                  child: const Text("Save"))
            ],
          );
        });
  }

  removeConfigurationPath(int index) {
    setState(() {
      textFormFieldList.removeAt(index);
    });
    PreferenceService.deleteConfigurationFilePath(index);
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
            SizedBox(
              width: 200,
              child: BouncingButton(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.save,
                      size: 20,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text("Save Config",
                        style: TextStyle(color: Colors.white, fontSize: 20))
                  ],
                ),
                onPressed: validatePaths,
              ),
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
