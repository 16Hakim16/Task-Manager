import 'package:get/get.dart';
import 'package:task_manager/db/db_helper.dart';
import 'package:task_manager/models/task.dart';

class TaskController extends GetxController {
  final RxList<Task> tasksList = <Task>[].obs;

  Future<int> addTask({required Task task}) {
    return DBHelper.insert(task);
  }

  getTasks() async {
    final List<Map<String, dynamic>> tasks = await DBHelper.query();
    tasksList.assignAll(tasks.map((e) => Task.fromJson(e)).toList());
  }

  deleteTask(int taskId) async {
    await DBHelper.delete(taskId);
    getTasks();
  }

  markTaskAsCompleted(Task task) async {
    await DBHelper.update(task);
    getTasks();
  }
}
