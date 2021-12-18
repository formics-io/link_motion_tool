import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final String path;
  const CustomTextFormField({Key? key, required this.path}) : super(key: key);

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
    folderPath = widget.path.split('\\')[widget.path.split('\\').length - 2];
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
