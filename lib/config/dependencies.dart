import 'package:get_it/get_it.dart';
import 'package:loop_task/domain/repositories/task_repository.dart';
import 'package:loop_task/data/repositories/task/sqlite_task_repository.dart';
import 'package:loop_task/data/services/task/task_service.dart';
import 'package:loop_task/main_viewmodel.dart';

void setupDependencies() {
  final getIt = GetIt.instance;

  getIt.registerLazySingleton<TaskRepository>(() => SqliteTaskRepository());

  getIt.registerLazySingleton<TaskService>(
    () => TaskService(getIt<TaskRepository>()),
  );

  getIt.registerLazySingleton<MainViewmodel>(() => MainViewmodel());
}
