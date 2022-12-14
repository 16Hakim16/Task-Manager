import 'package:flutter/material.dart';
import 'package:task_manager/ui/theme.dart';

class MyButton extends StatelessWidget {
  const MyButton({Key? key, required this.label, required this.onTap}) : super(key: key);

  final String label;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: primaryClr),
        child: Text(label, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
      ),
    );
  }
}
