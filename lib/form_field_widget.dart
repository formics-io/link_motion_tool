import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final String path;
  final String name;
  final String? imagePath;
  final String? height;
  final String? width;
  final String? color;

  const CustomTextFormField({Key? key, required this.path, required this.name, this.imagePath, this.height, this.width, this.color})
      : super(key: key);

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late TextEditingController _textEditingController;
  late String folderPath;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    _textEditingController.text = widget.path;
    folderPath = widget.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        label: Text(folderPath),
        contentPadding: const EdgeInsets.all(20),
        suffixIcon: const Icon(Icons.app_settings_alt_outlined),
        hintText: "Select config path",
        border: const OutlineInputBorder(),
      ),
      controller: _textEditingController,
    );
  }
}
