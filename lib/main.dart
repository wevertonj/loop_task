import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:loop_task/config/dependencies.dart';
import 'package:loop_task/config/go_router.dart';
import 'package:loop_task/main_viewmodel.dart';
import 'package:loop_task/utils/constants/app_text.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  runApp(const Main());
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  final mainViewmodel = GetIt.I<MainViewmodel>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    mainViewmodel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: mainViewmodel,
      builder: (context, child) {
        return MaterialApp.router(
          title: AppText.appName,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          routerDelegate: goRouter.routerDelegate,
          routeInformationParser: goRouter.routeInformationParser,
          routeInformationProvider: goRouter.routeInformationProvider,
        );
      },
    );
  }
}
