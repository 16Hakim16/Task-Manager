import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/ui/size_config.dart';
import 'package:task_manager/ui/theme.dart';

class InputField extends StatelessWidget {
  const InputField({
    Key? key,
    required this.title,
    required this.hint,
    this.controller,
    this.widget,
  }) : super(key: key);

  final String title;
  final String hint;
  final TextEditingController? controller;
  final Widget? widget;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              title,
              style: titleStyle,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            autofocus: false,
            readOnly: widget != null ? true : false,
            style: subTitleStyle,
            cursorColor: Get.isDarkMode ? Colors.grey[100] : Colors.grey[700],
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: subTitleStyle,
              suffixIcon: widget,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: primaryClr,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        ]));
  }
}
