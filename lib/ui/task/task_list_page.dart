import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

import 'package:loop_task/domain/entities/task_entity.dart';
import 'package:loop_task/main_viewmodel.dart';
import 'package:loop_task/utils/constants/app_text.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage>
    with TickerProviderStateMixin {
  final MainViewmodel _viewmodel = GetIt.I<MainViewmodel>();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String? _editingTaskId;
  final Map<String, TextEditingController> _editControllers = {};
  final Map<String, FocusNode> _editFocusNodes = {};

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _createController;
  late Animation<double> _createAnimation;
  String? _completedTaskId;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Task> _localTasks = [];
  String? _newlyCreatedTaskId;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _createController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _createAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _createController, curve: Curves.easeOut),
    );

    _viewmodel.addListener(_onViewModelChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncLocalTasks();
    });
  }

  void _syncLocalTasks() {
    final newTasks = _viewmodel.tasks;

    for (int i = _localTasks.length - 1; i >= 0; i--) {
      final task = _localTasks[i];
      if (!newTasks.any((t) => t.id == task.id)) {
        _localTasks.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildRemovedItem(task, animation),
        );
      }
    }

    for (int i = 0; i < newTasks.length; i++) {
      final newTask = newTasks[i];
      if (i >= _localTasks.length || _localTasks[i].id != newTask.id) {
        _localTasks.insert(i, newTask);
        _listKey.currentState?.insertItem(i);
      }
    }
  }

  void _onViewModelChange() {
    if (mounted) {
      _syncLocalTasks();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _viewmodel.removeListener(_onViewModelChange);
    _textController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    _createController.dispose();
    for (var controller in _editControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _editFocusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppText.taskListTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _viewmodel,
        builder: (context, child) {
          if (_viewmodel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewmodel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _viewmodel.errorMessage!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _viewmodel.loadTasks(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (_viewmodel.tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppText.emptyTaskList,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppText.emptyTaskListSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return _buildTaskList();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTaskDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: _showCompletedTasks,
          icon: const Icon(Icons.history),
          label: const Text('Tarefas Finalizadas'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: _localTasks.length,
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final task = _localTasks.removeAt(oldIndex);
        _localTasks.insert(newIndex, task);

        _viewmodel.reorderTasks(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        if (index >= _localTasks.length) return const SizedBox.shrink();
        final task = _localTasks[index];
        return _buildTaskItem(task, index);
      },
    );
  }

  Widget _buildRemovedItem(Task task, Animation<double> animation) {
    return const SizedBox.shrink();
  }

  Widget _buildTaskItem(Task task, int index) {
    final isEditing = _editingTaskId == task.id;
    final isCompleted = _completedTaskId == task.id;
    final isNewlyCreated = _newlyCreatedTaskId == task.id;

    return AnimatedBuilder(
      key: ValueKey(task.id),
      animation: isNewlyCreated ? _createAnimation : _fadeAnimation,
      builder: (context, child) {
        final opacity = isCompleted && _fadeController.isAnimating
            ? _fadeAnimation.value
            : isNewlyCreated && _createController.isAnimating
            ? _createAnimation.value
            : 1.0;

        final height = isCompleted && _fadeController.isAnimating
            ? _fadeAnimation.value
            : 1.0;

        Widget listTile = ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.drag_handle,
                    color: Theme.of(context).colorScheme.outline,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _completeTask(task),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
              ),
            ],
          ),
          title: isEditing
              ? _buildEditingInput(task)
              : Text(
                  task.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted
                        ? Theme.of(context).colorScheme.outline
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
          trailing: isEditing
              ? IconButton(
                  onPressed: () => _saveEdit(task),
                  icon: const Icon(Icons.check),
                  iconSize: 20,
                )
              : PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, task),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Row(
                        children: [
                          Icon(Icons.copy, size: 20),
                          SizedBox(width: 8),
                          Text('Duplicar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Deletar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
          onTap: isEditing
              ? null
              : isCompleted
              ? null
              : () => _completeTask(task),
        );

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          height: height * 70,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: opacity,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: listTile,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditingInput(Task task) {
    if (!_editControllers.containsKey(task.id)) {
      _editControllers[task.id] = TextEditingController(text: task.title);
      _editFocusNodes[task.id] = FocusNode();
    }

    return TextField(
      controller: _editControllers[task.id],
      focusNode: _editFocusNodes[task.id],
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      onSubmitted: (_) => _saveEdit(task),
    );
  }

  void _startEditing(Task task) {
    setState(() {
      _editingTaskId = task.id;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _editFocusNodes[task.id]?.requestFocus();
    });
  }

  void _saveEdit(Task task) {
    final newTitle = _editControllers[task.id]?.text.trim() ?? '';
    if (newTitle.isNotEmpty && newTitle != task.title) {
      final updatedTask = Task(
        id: task.id,
        title: newTitle,
        status: task.status,
        createdAt: task.createdAt,
        updatedAt: DateTime.now(),
        completedAt: task.completedAt,
        parentId: task.parentId,
        order: task.order,
      );
      _viewmodel.updateTask(updatedTask);
    }
    setState(() {
      _editingTaskId = null;
    });
  }

  void _handleMenuAction(String action, Task task) {
    switch (action) {
      case 'edit':
        _startEditing(task);
        break;
      case 'duplicate':
        _duplicateTask(task);
        break;
      case 'delete':
        _deleteTask(task);
        break;
    }
  }

  void _deleteTask(Task task) {
    _confirmDeleteTask(task.id);
  }

  void _duplicateTask(Task task) {
    _viewmodel.createTask(task.title).then((newTask) {
      if (newTask != null) {
        _showCreationAnimation(newTask.id);
        _showSuccessMessage('Tarefa duplicada');
      }
    });
  }

  void _showCreationAnimation(String taskId) {
    setState(() {
      _newlyCreatedTaskId = taskId;
    });
    _createController.forward().then((_) {
      if (mounted) {
        setState(() {
          _newlyCreatedTaskId = null;
        });
        _createController.reset();
      }
    });
  }

  void _showCreateTaskDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Tarefa'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Título da tarefa'),
          onSubmitted: (title) {
            Navigator.pop(context);
            if (title.trim().isNotEmpty) {
              _viewmodel.createTask(title.trim()).then((task) {
                if (task != null) {
                  _showCreationAnimation(task.id);
                  _showSuccessMessage(AppText.taskCreated);
                }
              });
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                _viewmodel.createTask(title).then((task) {
                  if (task != null) {
                    _showCreationAnimation(task.id);
                    _showSuccessMessage(AppText.taskCreated);
                  }
                });
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _showCompletedTasks() {
    _viewmodel.loadCompletedTasks();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Tarefas Finalizadas',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedBuilder(
                animation: _viewmodel,
                builder: (context, child) {
                  if (_viewmodel.completedTasks.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma tarefa finalizada'),
                    );
                  }
                  return ListView.builder(
                    itemCount: _viewmodel.completedTasks.length,
                    itemBuilder: (context, index) {
                      final task = _viewmodel.completedTasks[index];
                      return ListTile(
                        title: Text(
                          task.title,
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        subtitle: task.completedAt != null
                            ? Text(
                                'Concluída em ${task.completedAt!.day}/${task.completedAt!.month}/${task.completedAt!.year}',
                              )
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _completeTask(Task task) {
    setState(() {
      _completedTaskId = task.id;
    });
    _showSuccessMessage(AppText.taskCompleted);

    Future.delayed(const Duration(seconds: 2), () {
      if (_completedTaskId == task.id) {
        _startFadeOutTimer();
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (_completedTaskId == task.id) {
        _viewmodel.completeTask(task.id).then((result) {
          if (result?.newTask != null) {
            _showCreationAnimation(result!.newTask.id);
          }
        });
      }
    });
  }

  void _confirmDeleteTask(String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppText.confirmDelete),
        content: const Text(AppText.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppText.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _viewmodel.deleteTask(taskId).then((success) {
                if (success) {
                  _showSuccessMessage(AppText.taskDeleted);
                }
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text(AppText.delete),
          ),
        ],
      ),
    );
  }

  void _startFadeOutTimer() {
    _fadeController.reset();
    _fadeController.forward().then((_) {
      setState(() {
        _completedTaskId = null;
      });
    });
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
