import 'package:link_motion_tool/config_file_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PreferenceService {
  static late SharedPreferences _preferences;
  static String softwarePathKey = "software_path";
  static String softwareConfigPathKey = "software_config_path";
  static String configFilePathKey = "config_file_path_list";
  static String imagePathKey = "image_path";
  static String heightKey = "height";
  static String widthKey = "width";
  static String colorKey = "color";

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

  /*static Future<void> addConfigurationFilePath(
      ConfigFileModel configFileModel) async {
    await initializePrefrence();
    List<ConfigFileModel> configPathList = await getConfigurationFilePath();
    configPathList.add(configFileModel);

    _preferences.setString(
        configFilePathKey, configFileModelToJson(configPathList));
  }*/

  static Future<void> addConfigurationFilePath(ConfigFileModel configFileModel, String imagePath, String height, String width, String color) async {
    await initializePrefrence();
    List<ConfigFileModel> configPathList = await getConfigurationFilePath();
    configPathList.add(configFileModel);
    
    // Store the updated list of ConfigFileModel objects
    _preferences.setString(configFilePathKey, configFileModelToJson(configPathList));

    // Store the imagePath along with a unique key related to the config file
    String imagePathKey = "${configFileModel.path}_imagePath";
    _preferences.setString(imagePathKey, imagePath);

    // Store the height and width associated with the config file
    String heightKey = "${configFileModel.path}_height";
    _preferences.setString(heightKey, height);

    String widthKey = "${configFileModel.path}_width";
    _preferences.setString(widthKey, width);

    String colorKey = "${configFileModel.path}_color";
    _preferences.setString(colorKey, color);
  }

  static Future<void> deleteConfigurationFilePath(int index) async {
    List<ConfigFileModel> configPathList = await getConfigurationFilePath();
    configPathList.removeAt(index);
    _preferences.setString(
        configFilePathKey, configFileModelToJson(configPathList));
  }

  /*static Future<List<ConfigFileModel>> getConfigurationFilePath() async {
    String jsonData = _preferences.getString(configFilePathKey) ?? '';
    return jsonData.isNotEmpty ? configFileModelFromJson(jsonData) : [];
  }*/

  static Future<List<ConfigFileModel>> getConfigurationFilePath() async {
    await initializePrefrence();

    String jsonData = _preferences.getString(configFilePathKey) ?? '';

    List<ConfigFileModel> configList =
      jsonData.isNotEmpty ? configFileModelFromJson(jsonData) : [];

    for (int i = 0; i < configList.length; i++) {
      String imagePathKey = "${configList[i].path}_imagePath";
      String heightKey = "${configList[i].path}_height";
      String widthKey = "${configList[i].path}_width";
      String colorKey = "${configList[i].path}_color";

      configList[i].imagePath = _preferences.getString(imagePathKey) ?? '';
      configList[i].height = _preferences.getString(heightKey) ?? '';
      configList[i].width = _preferences.getString(widthKey) ?? '';
      configList[i].color = _preferences.getString(colorKey) ?? '';
    }
    return configList;
  }
}
