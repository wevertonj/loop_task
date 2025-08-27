import 'package:go_router/go_router.dart';
import 'package:loop_task/config/app_routes.dart';
import 'package:loop_task/ui/task/task_list_page.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      name: AppRoutes.home,
      path: '/',
      builder: (context, state) => const TaskListPage(),
    ),
  ],
);
