import 'package:sqflite/sqflite.dart';
import 'package:task_manager/models/task.dart';

class DBHelper {
  static Database? _database;
  static const int _version = 1;
  static const String _tableName = 'tasks';

  static Future<void> initDB() async {
    if (_database != null) {
      return;
    } else {
      try {
        // Get a location using getDatabasesPath
        var databasesPath = await getDatabasesPath() + 'taskManagerDB.db';

        // open the database
        _database = await openDatabase(databasesPath, version: _version, onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute('CREATE TABLE $_tableName ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'title STRING, '
              'note TEXT, '
              'date STRING, '
              'startTime STRING, '
              'endTime STRING, '
              'isCompleted INTEGER, '
              'color INTEGER, '
              'remind INTEGER, '
              'repeat STRING '
              ')');
        });
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  static Future<int> insert(Task task) async {
    return await _database!.insert(_tableName, task.toJson());
  }

  static Future<List<Map<String, dynamic>>> query() async {
    return await _database!.query(
      _tableName,
      orderBy: "id DESC",
    );
  }

  static Future<int> delete(int id) async {
    return await _database!.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> update(Task task) async {
    return await _database!.rawUpdate('UPDATE $_tableName SET isCompleted = ? WHERE id = ?', [1, task.id]);
  }
}
