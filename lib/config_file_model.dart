import 'dart:convert';

class ConfigFileModel {

  ConfigFileModel({
    required this.path,
    this.imagePath,
    required this.name,
    this.height,
    this.width,
    this.color,
  });

  String path;
  String? imagePath;
  String name;
  String? height;
  String? width;
  String? color;

  factory ConfigFileModel.fromJson(Map<String, dynamic> json) =>
      ConfigFileModel(
        path: json["path"],
        imagePath: json["imagePath"] ?? '',
        name: json["name"],
        height: json["height"] ?? '',
        width: json["width"] ?? '',
        color: json["color"] ?? '',
      );

  Map<String, dynamic> toJson() => {
    "path": path,
    "imagePath": imagePath ?? '',
    "name": name,
    "height": height ?? '',
    "width": width ?? '',
    "color": color ?? '',
    };
}

List<ConfigFileModel> configFileModelFromJson(String str) {
  final jsonData = json.decode(str);
  return List<ConfigFileModel>.from(
      jsonData.map((x) => ConfigFileModel.fromJson(x))
  );
}

// Function to convert a list of ConfigFileModel objects to a JSON string
String configFileModelToJson(List<ConfigFileModel> data) {
  return json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}