import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static late SharedPreferences _preferences;
  static String softwarePathKey = "software_path";
  static String softwareConfigPathKey = "software_config_path";
  static String configFilePathKey = "config_file_path_list";

  static Future<void> initializePrefrence() async {
    _preferences = await SharedPreferences.getInstance();
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

  static Future<void> addConfigurationFilePath(String path) async {
    await initializePrefrence();
    List<String> pathList = await getConfigurationFilePath();
    pathList.add(path);

    _preferences.setStringList(configFilePathKey, pathList);
  }

  static Future<void> deleteConfigurationFilePath(int index) async {
    List<String> pathList = await getConfigurationFilePath();
    pathList.removeAt(index);
    _preferences.setStringList(configFilePathKey, pathList);
  }

  static Future<List<String>> getConfigurationFilePath() async {
    return _preferences.getStringList(configFilePathKey) ?? [];
  }
}
