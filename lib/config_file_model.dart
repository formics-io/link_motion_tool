import 'dart:convert';

List<ConfigFileModel> configFileModelFromJson(String str) =>
    List<ConfigFileModel>.from(
        json.decode(str).map((x) => ConfigFileModel.fromJson(x)));

String configFileModelToJson(List<ConfigFileModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ConfigFileModel {
  ConfigFileModel({
    required this.path,
    required this.name,
  });

  String path;
  String name;

  factory ConfigFileModel.fromJson(Map<String, dynamic> json) =>
      ConfigFileModel(
        path: json["path"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "path": path,
        "name": name,
      };
}
