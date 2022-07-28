import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/controllers/task_controller.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/ui/theme.dart';
import 'package:task_manager/ui/widgets/button.dart';
import 'package:task_manager/ui/widgets/input_field.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _startTime = DateFormat('hh:mm a').format(DateTime.now());
  String _endTime = DateFormat('hh:mm a').format(DateTime.now().add(const Duration(minutes: 15))).toString();
  int _selectedRemind = 5;
  final List<int> _remindList = [5, 10, 15, 20];
  String _selectedRepeat = 'None';
  final List<String> _repeatList = ['None', 'Daily', 'Weekly', 'Monthly'];
  int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Add Task',
              style: headingStyle,
            ),
            const SizedBox(height: 20),
            InputField(
              title: 'Title',
              hint: 'Enter Title',
              controller: _titleController,
            ),
            InputField(
              title: 'Note',
              hint: 'Enter Note',
              controller: _noteController,
            ),
            InputField(
              title: 'Date',
              hint: DateFormat.yMd().format(_selectedDate),
              widget: IconButton(
                  onPressed: () => _getDateFromUser(),
                  icon: const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey,
                  )),
            ),
            Row(
              children: [
                Expanded(
                  child: InputField(
                    title: 'Start Time',
                    hint: _startTime,
                    widget: IconButton(
                        onPressed: () => _getTimeFromUser(isStartTime: true),
                        icon: const Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey,
                        )),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: InputField(
                    title: 'End Time',
                    hint: _endTime,
                    widget: IconButton(
                        onPressed: () => _getTimeFromUser(isStartTime: false),
                        icon: const Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey,
                        )),
                  ),
                ),
              ],
            ),
            InputField(
              title: 'Remind',
              hint: '$_selectedRemind minutes early',
              widget: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButton(
                  dropdownColor: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(12),
                  items: _remindList
                      .map<DropdownMenuItem<String>>((int value) => DropdownMenuItem<String>(
                          value: value.toString(),
                          child: Text(
                            value.toString(),
                            style: const TextStyle(color: Colors.white),
                          )))
                      .toList(),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                  iconSize: 32,
                  elevation: 4,
                  underline: Container(),
                  style: subTitleStyle,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRemind = int.parse(newValue!);
                    });
                  },
                ),
              ),
            ),
            InputField(
              title: 'Repeat',
              hint: _selectedRepeat,
              widget: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButton(
                  dropdownColor: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(12),
                  items: _repeatList
                      .map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.white),
                          )))
                      .toList(),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                  iconSize: 32,
                  elevation: 4,
                  underline: Container(),
                  style: subTitleStyle,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRepeat = newValue!;
                    });
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _colorPalette(),
                MyButton(label: 'Create Task', onTap: _validateSubmission),
              ],
            )
          ],
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Get.isDarkMode ? Colors.white : darkGreyClr,
        ),
        onPressed: () => Get.back(),
      ),
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
    );
  }

  Column _colorPalette() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: titleStyle,
        ),
        const SizedBox(
          height: 8,
        ),
        Wrap(
          children: List.generate(
              3,
              (index) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = index;
                      });
                    },
                    child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CircleAvatar(
                          backgroundColor: index == 0
                              ? primaryClr
                              : index == 1
                                  ? pinkClr
                                  : orangeClr,
                          child: _selectedColor == index ? const Icon(Icons.done, color: Colors.white) : null,
                        )),
                  )),
        ),
      ],
    );
  }

  _validateSubmission() {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      _addTaskToDB();
      _taskController.getTasks();
      Get.back();
      Get.snackbar('Success', 'Task added successfully',
          duration: const Duration(seconds: 2),
          icon: const Icon(
            Icons.done_rounded,
            color: Colors.green,
          ),
          snackPosition: SnackPosition.BOTTOM);
    } else if (_titleController.text.isEmpty || _noteController.text.isEmpty) {
      Get.snackbar('Required', 'All fields are required',
          duration: const Duration(seconds: 2),
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
          ),
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('Error', 'Something went wrong',
          duration: const Duration(seconds: 2),
          icon: const Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
          ),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  _addTaskToDB() {
    _taskController.addTask(
      task: Task(
        title: _titleController.text,
        note: _noteController.text,
        remind: _selectedRemind,
        repeat: _selectedRepeat,
        date: _selectedDate.toString(),
        startTime: _startTime,
        endTime: _endTime,
        color: _selectedColor,
        isCompleted: 0,
      ),
    );
  }

  _getDateFromUser() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  _getTimeFromUser({required bool isStartTime}) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? TimeOfDay.fromDateTime(DateTime.now())
          : TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 15))),
    );
    if (pickedTime != null) {
      isStartTime
          ? setState(() {
              _startTime = pickedTime.format(context);
            })
          : setState(() {
              _endTime = pickedTime.format(context);
            });
    }
  }
}
