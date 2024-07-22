import 'dart:convert';

List<ConfigFileModel> configFileModelFromJson(String str) =>
    List<ConfigFileModel>.from(
        json.decode(str).map((x) => ConfigFileModel.fromJson(x)));

String configFileModelToJson(List<ConfigFileModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ConfigFileModel {

  ConfigFileModel({
    required this.path,
    this.imagePath,
    required this.name,
    this.height,
    this.width,
  });

  String path;
  String? imagePath;
  String name;
  String? height;
  String? width;

  factory ConfigFileModel.fromJson(Map<String, dynamic> json) =>
      ConfigFileModel(
        path: json["path"],
        imagePath: json["image"] ?? '',
        name: json["name"],
        height: json["height"] ?? '',
        width: json["width"] ?? '',
      );

  Map<String, dynamic> toJson() => {
    "path": path,
    "imagePath": imagePath ?? '',
    "name": name,
    "height": height ?? '',
    "width": width ?? '',
  };
}
