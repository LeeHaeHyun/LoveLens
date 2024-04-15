import 'package:flutter/material.dart';

class DiaryEditor extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  const DiaryEditor({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
      ),
      maxLines: null,
      validator: (value) {
        if (value!.isEmpty) {
          return '$hintText을 입력해주세요!';
        }
        return null;
      },
    );
  }
}
