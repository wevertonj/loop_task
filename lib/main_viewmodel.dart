import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

import 'package:loop_task/data/services/task/task_service.dart';
import 'package:loop_task/domain/entities/task_entity.dart';
import 'package:loop_task/domain/enums/task_status.dart';
import 'package:loop_task/utils/constants/app_text.dart';

class MainViewmodel extends ChangeNotifier {
  final TaskService _taskService = GetIt.I<TaskService>();

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  List<Task> _completedTasks = [];
  List<Task> get completedTasks => _completedTasks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  MainViewmodel() {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await loadTasks();
    } catch (e) {
      _setError('Erro ao inicializar o app: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<void> loadTasks() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _taskService.getAllTasks();

      result.fold(
        (tasks) {
          _tasks = tasks
              .where((task) => task.status == TaskStatus.todo)
              .toList();
          _tasks.sort((a, b) => a.order.compareTo(b.order));
          _setLoading(false);
          notifyListeners();
        },
        (failure) {
          _setError('${AppText.errorGeneric}: ${failure.toString()}');
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError('Erro ao carregar tarefas: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<void> loadCompletedTasks() async {
    try {
      final result = await _taskService.getCompletedTasks();

      result.fold(
        (tasks) {
          _completedTasks = tasks;
          notifyListeners();
        },
        (failure) {
          _setError('${AppText.errorGeneric}: ${failure.toString()}');
        },
      );
    } catch (e) {
      _setError('Erro ao carregar tarefas concluídas: ${e.toString()}');
    }
  }

  Future<Task?> createTask(String title) async {
    _clearError();

    final result = await _taskService.createTask(title);

    return result.fold(
      (task) {
        _tasks.add(task);
        _tasks.sort((a, b) => a.order.compareTo(b.order));
        notifyListeners();
        return task;
      },
      (failure) {
        _setError(failure.toString());
        return null;
      },
    );
  }

  Future<Task?> updateTask(Task task) async {
    _clearError();

    final result = await _taskService.updateTask(task);

    return result.fold(
      (updatedTask) {
        final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
        if (index != -1) {
          _tasks[index] = updatedTask;
          notifyListeners();
        }
        return updatedTask;
      },
      (failure) {
        _setError(failure.toString());
        return null;
      },
    );
  }

  Future<TaskCompletionResult?> completeTask(String taskId) async {
    _clearError();

    final result = await _taskService.completeTask(taskId);

    return result.fold(
      (completionResult) {
        _tasks.removeWhere((t) => t.id == taskId);
        _tasks.add(completionResult.newTask);
        _tasks.sort((a, b) => a.order.compareTo(b.order));
        notifyListeners();
        return completionResult;
      },
      (failure) {
        _setError(failure.toString());
        return null;
      },
    );
  }

  Future<bool> undoTaskCompletion(
    String completedTaskId,
    String newTaskId,
  ) async {
    _clearError();

    final result = await _taskService.undoTaskCompletion(
      completedTaskId,
      newTaskId,
    );

    return result.fold(
      (_) async {
        final newTaskIndex = _tasks.indexWhere((t) => t.id == newTaskId);
        if (newTaskIndex != -1) {
          _tasks.removeAt(newTaskIndex);
        }

        final restoredTaskResult = await _taskService.getTaskById(
          completedTaskId,
        );
        await restoredTaskResult.fold((restoredTask) async {
          _tasks.add(restoredTask);
          _tasks.sort((a, b) => a.order.compareTo(b.order));
        }, (failure) {});

        notifyListeners();
        return true;
      },
      (failure) {
        _setError(failure.toString());
        return false;
      },
    );
  }

  Future<bool> deleteTask(String taskId) async {
    _clearError();

    final result = await _taskService.deleteTask(taskId);

    return result.fold(
      (_) {
        _tasks.removeWhere((task) => task.id == taskId);
        notifyListeners();
        return true;
      },
      (failure) {
        _setError(failure.toString());
        return false;
      },
    );
  }

  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final task = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, task);

    for (int i = 0; i < _tasks.length; i++) {
      final updatedTask = Task(
        id: _tasks[i].id,
        title: _tasks[i].title,
        status: _tasks[i].status,
        createdAt: _tasks[i].createdAt,
        updatedAt: DateTime.now(),
        completedAt: _tasks[i].completedAt,
        parentId: _tasks[i].parentId,
        order: i,
      );
      _tasks[i] = updatedTask;
      await _taskService.updateTask(updatedTask);
    }

    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
