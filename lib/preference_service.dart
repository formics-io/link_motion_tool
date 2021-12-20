import 'package:link_motion_tool/config_file_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static late SharedPreferences _preferences;
  static String softwarePathKey = "software_path";
  static String softwareConfigPathKey = "software_config_path";
  static String configFilePathKey = "config_file_path_list";

  static Future<void> initializePrefrence() async {
    _preferences = await SharedPreferences.getInstance();
    // _preferences.clear();
  }

  static Future<String> getSoftwarePath() async {
    await initializePrefrence();
    return _preferences.getString(softwarePathKey) ?? '';
  }

  static Future<void> setSoftwarePath(String path) async {
    await initializePrefrence();
    _preferences.setString(softwarePathKey, path);
  }

  static Future<String> getSoftwareConfigPath() async {
    await initializePrefrence();
    return _preferences.getString(softwareConfigPathKey) ?? '';
  }

  static Future<void> setSoftwareConfigPath(String path) async {
    await initializePrefrence();
    _preferences.setString(softwareConfigPathKey, path);
  }

  static Future<void> addConfigurationFilePath(
      ConfigFileModel configFileModel) async {
    await initializePrefrence();
    List<ConfigFileModel> configPathList = await getConfigurationFilePath();
    configPathList.add(configFileModel);

    _preferences.setString(
        configFilePathKey, configFileModelToJson(configPathList));
  }

  static Future<void> deleteConfigurationFilePath(int index) async {
    List<ConfigFileModel> configPathList = await getConfigurationFilePath();
    configPathList.removeAt(index);
    _preferences.setString(
        configFilePathKey, configFileModelToJson(configPathList));
  }

  static Future<List<ConfigFileModel>> getConfigurationFilePath() async {
    String jsonData = _preferences.getString(configFilePathKey) ?? '';
    return jsonData.isNotEmpty ? configFileModelFromJson(jsonData) : [];
  }
}
