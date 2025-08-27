import 'package:result_dart/result_dart.dart';
import 'package:uuid/uuid.dart';

import 'package:loop_task/data/exceptions/exceptions.dart';
import 'package:loop_task/domain/entities/task_entity.dart';
import 'package:loop_task/domain/enums/task_status.dart';
import 'package:loop_task/domain/repositories/task_repository.dart';
import 'package:loop_task/utils/constants/app_text.dart';

class TaskService {
  final TaskRepository _taskRepository;
  final Uuid _uuid = const Uuid();

  TaskService(this._taskRepository);

  AsyncResult<List<Task>> getAllTasks() {
    return _taskRepository.getAllTasks();
  }

  AsyncResult<Task> getTaskById(String id) {
    return _taskRepository.getTaskById(id);
  }

  AsyncResult<Task> createTask(String title) async {
    if (title.trim().isEmpty) {
      return Failure(TaskValidationException(AppText.errorEmptyTitle));
    }

    final allTasksResult = await _taskRepository.getAllTasks();
    int nextOrder = 0;

    allTasksResult.fold((tasks) {
      final activeTasks = tasks
          .where((t) => t.status == TaskStatus.todo)
          .toList();
      if (activeTasks.isNotEmpty) {
        nextOrder =
            activeTasks.map((t) => t.order).reduce((a, b) => a > b ? a : b) + 1;
      }
    }, (failure) => {});

    final task = Task(
      id: _uuid.v4(),
      title: title.trim(),
      status: TaskStatus.todo,
      order: nextOrder,
    );

    return _taskRepository.createTask(task);
  }

  AsyncResult<Task> updateTask(Task task) async {
    if (task.title.trim().isEmpty) {
      return Failure(TaskValidationException(AppText.errorEmptyTitle));
    }

    final updatedTask = Task(
      id: task.id,
      title: task.title.trim(),
      status: task.status,
      createdAt: task.createdAt,
      updatedAt: DateTime.now(),
      completedAt: task.completedAt,
      parentId: task.parentId,
      order: task.order,
    );

    return _taskRepository.updateTask(updatedTask);
  }

  AsyncResult<TaskCompletionResult> completeTask(String taskId) async {
    final taskResult = await _taskRepository.getTaskById(taskId);

    return taskResult.fold((task) async {
      if (task.status == TaskStatus.done) {
        return Failure(TaskValidationException('Tarefa já foi concluída'));
      }

      final completedTask = Task(
        id: task.id,
        title: task.title,
        status: TaskStatus.done,
        createdAt: task.createdAt,
        updatedAt: DateTime.now(),
        completedAt: DateTime.now(),
        parentId: task.parentId,
        order: task.order,
      );

      final updateResult = await _taskRepository.updateTask(completedTask);

      return updateResult.fold((updatedTask) async {
        final allTasksResult = await _taskRepository.getAllTasks();
        int nextOrder = 0;

        allTasksResult.fold((tasks) {
          final activeTasks = tasks
              .where((t) => t.status == TaskStatus.todo)
              .toList();
          if (activeTasks.isNotEmpty) {
            nextOrder =
                activeTasks
                    .map((t) => t.order)
                    .reduce((a, b) => a > b ? a : b) +
                1;
          }
        }, (failure) => {});

        final newTask = Task(
          id: _uuid.v4(),
          title: task.title,
          status: TaskStatus.todo,
          parentId: task.id,
          order: nextOrder,
        );

        final createResult = await _taskRepository.createTask(newTask);

        return createResult.fold(
          (createdTask) => Success(
            TaskCompletionResult(
              completedTask: updatedTask,
              newTask: createdTask,
            ),
          ),
          (failure) => Failure(failure),
        );
      }, (failure) => Failure(failure));
    }, (failure) => Failure(failure));
  }

  AsyncResult<Unit> undoTaskCompletion(
    String completedTaskId,
    String newTaskId,
  ) async {
    final completedTaskResult = await _taskRepository.getTaskById(
      completedTaskId,
    );

    return completedTaskResult.fold((completedTask) async {
      if (completedTask.status != TaskStatus.done) {
        return Failure(TaskValidationException('Tarefa não está concluída'));
      }

      final restoredTask = Task(
        id: completedTask.id,
        title: completedTask.title,
        status: TaskStatus.todo,
        createdAt: completedTask.createdAt,
        updatedAt: DateTime.now(),
        completedAt: null,
        parentId: completedTask.parentId,
        order: completedTask.order,
      );

      final updateResult = await _taskRepository.updateTask(restoredTask);

      return updateResult.fold((_) async {
        final deleteResult = await _taskRepository.deleteTask(newTaskId);

        return deleteResult.fold(
          (_) => Success.unit(),
          (failure) => Failure(failure),
        );
      }, (failure) => Failure(failure));
    }, (failure) => Failure(failure));
  }

  AsyncResult<Unit> deleteTask(String id) {
    return _taskRepository.deleteTask(id);
  }

  AsyncResult<List<Task>> getTasksByParentId(String? parentId) {
    return _taskRepository.getTasksByParentId(parentId);
  }

  AsyncResult<List<Task>> getCompletedTasks() {
    return _taskRepository.getCompletedTasks();
  }

  AsyncResult<Unit> clearAllTasks() {
    return _taskRepository.clearAllTasks();
  }
}

class TaskCompletionResult {
  final Task completedTask;
  final Task newTask;

  TaskCompletionResult({required this.completedTask, required this.newTask});
}
