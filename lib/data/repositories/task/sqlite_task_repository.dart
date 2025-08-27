import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:result_dart/result_dart.dart';
import 'package:loop_task/domain/entities/task_entity.dart';
import 'package:loop_task/domain/enums/task_status.dart';
import 'package:loop_task/domain/repositories/task_repository.dart';
import 'package:loop_task/data/exceptions/exceptions.dart' as app_exceptions;
import 'package:loop_task/utils/constants/app_text.dart';

class SqliteTaskRepository implements TaskRepository {
  static const String _tableName = 'tasks';
  static const String _databaseName = 'loop_task.db';
  static const int _databaseVersion = 2;

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        completed_at TEXT,
        parent_id TEXT,
        task_order INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $_tableName ADD COLUMN task_order INTEGER DEFAULT 0',
      );
    }
  }

  @override
  AsyncResult<List<Task>> getAllTasks() async {
    try {
      final db = await database;
      final maps = await db.query(
        _tableName,
        where: 'status != ?',
        whereArgs: ['done'],
        orderBy: 'task_order ASC, created_at ASC',
      );

      final tasks = maps.map((map) => _taskFromMap(map)).toList();

      return Success(tasks);
    } catch (e) {
      return Failure(app_exceptions.DatabaseException(AppText.errorGeneric));
    }
  }

  @override
  AsyncResult<List<Task>> getCompletedTasks() async {
    try {
      final db = await database;
      final maps = await db.query(
        _tableName,
        where: 'status = ?',
        whereArgs: ['done'],
        orderBy: 'completed_at DESC',
      );

      final tasks = maps.map((map) => _taskFromMap(map)).toList();

      return Success(tasks);
    } catch (e) {
      return Failure(app_exceptions.DatabaseException(AppText.errorGeneric));
    }
  }

  @override
  AsyncResult<Task> getTaskById(String id) async {
    try {
      final db = await database;
      final maps = await db.query(_tableName, where: 'id = ?', whereArgs: [id]);

      if (maps.isEmpty) {
        return Failure(
          app_exceptions.TaskNotFoundException(AppText.errorTaskNotFound),
        );
      }

      return Success(_taskFromMap(maps.first));
    } catch (e) {
      return Failure(app_exceptions.DatabaseException(AppText.errorGeneric));
    }
  }

  @override
  AsyncResult<Task> createTask(Task task) async {
    try {
      final db = await database;
      await db.insert(_tableName, _taskToMap(task));

      return Success(task);
    } catch (e) {
      return Failure(app_exceptions.DatabaseException(AppText.errorGeneric));
    }
  }

  @override
  AsyncResult<Task> updateTask(Task task) async {
    try {
      final db = await database;
      final count = await db.update(
        _tableName,
        _taskToMap(task),
        where: 'id = ?',
        whereArgs: [task.id],
      );

      if (count == 0) {
        return Failure(
          app_exceptions.TaskNotFoundException(AppText.errorTaskNotFound),
        );
      }

      return Success(task);
    } catch (e) {
      return Failure(app_exceptions.DatabaseException(AppText.errorGeneric));
    }
  }

  @override
  AsyncResult<Unit> deleteTask(String id) async {
    try {
      final db = await database;
      final count = await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        return Failure(
          app_exceptions.TaskNotFoundException(AppText.errorTaskNotFound),
        );
      }

      return Success.unit();
    } catch (e) {
      return Failure(app_exceptions.DatabaseException(AppText.errorGeneric));
    }
  }

  @override
  AsyncResult<List<Task>> getTasksByParentId(String? parentId) async {
    try {
      final db = await database;
      final maps = await db.query(
        _tableName,
        where: parentId != null ? 'parent_id = ?' : 'parent_id IS NULL',
        whereArgs: parentId != null ? [parentId] : null,
        orderBy: 'created_at DESC',
      );

      final tasks = maps.map((map) => _taskFromMap(map)).toList();

      return Success(tasks);
    } catch (e) {
      return Failure(app_exceptions.DatabaseException(AppText.errorGeneric));
    }
  }

  @override
  AsyncResult<Unit> clearAllTasks() async {
    try {
      final db = await database;
      await db.delete(_tableName);

      return Success.unit();
    } catch (e) {
      return Failure(app_exceptions.DatabaseException(AppText.errorGeneric));
    }
  }

  Map<String, dynamic> _taskToMap(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'status': task.status.name,
      'created_at': task.createdAt.toIso8601String(),
      'updated_at': task.updatedAt?.toIso8601String(),
      'completed_at': task.completedAt?.toIso8601String(),
      'parent_id': task.parentId,
      'task_order': task.order,
    };
  }

  Task _taskFromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      status: TaskStatus.values.firstWhere(
        (status) => status.name == map['status'],
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      parentId: map['parent_id'] as String?,
      order: map['task_order'] as int? ?? 0,
    );
  }
}
