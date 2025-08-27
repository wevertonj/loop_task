import 'package:result_dart/result_dart.dart';
import 'package:loop_task/domain/entities/task_entity.dart';

abstract class TaskRepository {
  AsyncResult<List<Task>> getAllTasks();
  AsyncResult<List<Task>> getCompletedTasks();
  AsyncResult<Task> getTaskById(String id);
  AsyncResult<Task> createTask(Task task);
  AsyncResult<Task> updateTask(Task task);
  AsyncResult<Unit> deleteTask(String id);
  AsyncResult<List<Task>> getTasksByParentId(String? parentId);
  AsyncResult<Unit> clearAllTasks();
}
