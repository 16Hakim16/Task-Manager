import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/controllers/task_controller.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/notification_services.dart';
import 'package:task_manager/services/theme_services.dart';
import 'package:task_manager/ui/pages/add_task_page.dart';
import 'package:task_manager/ui/pages/notification_screen.dart';
import 'package:task_manager/ui/size_config.dart';
import 'package:task_manager/ui/theme.dart';
import 'package:task_manager/ui/widgets/button.dart';
import 'package:task_manager/ui/widgets/task_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TaskController _taskController = Get.put(TaskController());
  DateTime _selectedDate = DateTime.now();
  final NotifyHelper _notifyHelper = NotifyHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _notifyHelper.initializeNotification();
    _notifyHelper.requestIOSPermissions();
    _taskController.getTasks();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(),
      body: Column(
        children: [
          _addTaskBar(),
          const SizedBox(height: 20),
          _addDateBar(),
          const SizedBox(height: 20),
          _showTasks(),
        ],
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round_outlined,
          color: Get.isDarkMode ? Colors.white : darkGreyClr,
        ),
        onPressed: () => ThemeServices().switchTheme(),
      ),
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: const CircleAvatar(
            backgroundImage: AssetImage('images/person.jpeg'),
          ),
        )
      ],
    );
  }

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style: subHeadingStyle,
              ),
              Text(
                'Today',
                style: headingStyle,
              )
            ],
          ),
          MyButton(
            label: '+ Add Task',
            onTap: () {
              Get.to(() => const AddTaskPage());
              // _taskController.getTasks();
            },
          ),
        ],
      ),
    );
  }

  _addDateBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: DatePicker(
        DateTime.now(),
        width: 80,
        height: 110,
        selectionColor: primaryClr,
        dateTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        dayTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        monthTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        initialSelectedDate: DateTime.now(),
        onDateChange: (newDate) {
          setState(() {
            _selectedDate = newDate;
          });
        },
      ),
    );
  }

  _showTasks() {
    return Expanded(
      child: Obx(
        () => RefreshIndicator(
          onRefresh: () => _taskController.getTasks(),
          child: _taskController.tasksList.isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: _taskController.tasksList.length,
                  scrollDirection: SizeConfig.orientation == Orientation.landscape ? Axis.horizontal : Axis.vertical,
                  itemBuilder: (BuildContext context, int index) {
                    if (_taskController.tasksList[index].date == _selectedDate.toString() ||
                        _taskController.tasksList[index].repeat == 'Daily' ||
                        _taskController.tasksList[index].repeat == 'None' ||
                        (_taskController.tasksList[index].repeat == 'Weekly' &&
                            _selectedDate.difference(DateTime.parse(_taskController.tasksList[index].date!)).inDays % 7 == 0) ||
                        (_taskController.tasksList[index].repeat == 'Monthly' &&
                            DateTime.parse(_taskController.tasksList[index].date!).day == _selectedDate.day)) {
                      _notifyHelper.scheduledNotification(
                        int.parse(_taskController.tasksList[index].startTime.toString().split(':')[0]),
                        int.parse(_taskController.tasksList[index].startTime.toString().split(':')[1].split(' ')[0]),
                        _taskController.tasksList[index],
                      );
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 300),
                        child: SlideAnimation(
                          duration: const Duration(milliseconds: 300),
                          child: FadeInAnimation(
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              margin: SizeConfig.orientation == Orientation.landscape
                                  ? const EdgeInsets.only(right: 12)
                                  : const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => Get.to(() => NotificationScreen(
                                    payload: _taskController.tasksList[index].title! +
                                        '|' +
                                        _taskController.tasksList[index].note! +
                                        '|' +
                                        _taskController.tasksList[index].date!)),
                                onLongPress: () => _showBottomSheet(context, _taskController.tasksList[index]),
                                child: TaskTile(
                                  task: _taskController.tasksList[index],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                )
              : _noTasksMsg(),
        ),
      ),
    );
  }

  _noTasksMsg() {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(seconds: 2),
          child: SingleChildScrollView(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              direction: SizeConfig.orientation == Orientation.landscape ? Axis.horizontal : Axis.vertical,
              children: [
                SizeConfig.orientation == Orientation.landscape
                    ? const SizedBox(
                        height: 10,
                      )
                    : const SizedBox(
                        height: 100,
                      ),
                SvgPicture.asset(
                  'images/task.svg',
                  color: primaryClr.withOpacity(0.7),
                  height: 90,
                  semanticsLabel: 'task',
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'You do not have any tasks yet!',
                  style: subTitleStyle,
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildBottomSheet({required String label, required Function() onTap, required Color clr, bool isClose = false}) {
    return GestureDetector(
      child: Container(
        height: 65,
        width: SizeConfig.screenWidth * 0.9,
        decoration: BoxDecoration(
          // border: Border.all(
          //     width: 2,
          //     color: isClose
          //         ? Get.isDarkMode
          //             ? Colors.grey[600]!
          //             : Colors.grey[300]!
          //         : clr),
          borderRadius: BorderRadius.circular(20),
          color: isClose ? Colors.transparent : clr,
        ),
        child: Center(
          child: Text(
            label,
            style: isClose
                ? titleStyle
                : titleStyle.copyWith(
                    color: Colors.white,
                  ),
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(4),
        // width: SizeConfig.screenWidth,
        // height: SizeConfig.orientation == Orientation.landscape
        //     ? task.isCompleted == 1
        //         ? SizeConfig.screenHeight * 0.6
        //         : SizeConfig.screenHeight * 0.8
        //     : task.isCompleted == 1
        //         ? SizeConfig.screenHeight * 0.40
        //         : SizeConfig.screenHeight * 0.39,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: Get.isDarkMode ? darkHeaderClr : Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 6,
              width: SizeConfig.screenWidth * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            task.isCompleted == 1
                ? Container()
                : _buildBottomSheet(
                    label: 'Task Completed',
                    onTap: () {
                      _taskController.markTaskAsCompleted(task);
                      _notifyHelper.cancelNotification(task);
                      Get.back();
                    },
                    clr: primaryClr),
            task.isCompleted == 1
                ? Container()
                : const SizedBox(
                    height: 8,
                  ),
            _buildBottomSheet(
              label: 'Delete Task',
              onTap: () {
                _taskController.deleteTask(task.id!);
                _notifyHelper.cancelNotification(task);
                Get.back();
              },
              clr: Colors.red[400]!,
            ),
            const SizedBox(
              height: 6,
            ),
            Divider(
              color: Get.isDarkMode ? Colors.grey : darkGreyClr,
            ),
            const SizedBox(
              height: 6,
            ),
            _buildBottomSheet(label: 'Cancel', onTap: () => Get.back(), clr: primaryClr),
            const SizedBox(
              height: 14,
            ),
          ],
        ),
      ),
    );
  }
}
