import 'package:loop_task/config/app_routes.dart';
import 'package:loop_task/config/go_router.dart';

class _RouteInfo {
  final String routeName;
  final Map<String, String> pathParameters;

  _RouteInfo(this.routeName, this.pathParameters);
}

class _NavigationEntry {
  final String originalRoute;
  final String routeName;
  final Map<String, String> pathParameters;
  final dynamic extra;

  _NavigationEntry({
    required this.originalRoute,
    required this.routeName,
    required this.pathParameters,
    this.extra,
  });
}

class AppNavigation {
  static final List<_NavigationEntry> _navigationStack = [];

  // Helper para analisar rota e extrair parâmetros
  static _RouteInfo _parseRoute(String routeWithParams) {
    // Se não contém parâmetros, retorna como está
    if (!routeWithParams.contains('/')) {
      return _RouteInfo(routeWithParams, {});
    }

    // Verifica se é uma rota com valores reais (ex: transactionDetails/123)
    // Precisamos comparar com rotas conhecidas do sistema
    final knownRoutes = {
      // Adicione outras rotas parametrizadas aqui conforme necessário
    };

    // Tenta encontrar uma rota correspondente
    for (final entry in knownRoutes.entries) {
      final routeName = entry.key;
      final routeTemplate = entry.value;

      if (_routeMatches(routeWithParams, routeTemplate)) {
        final parameters = _extractParameterValues(
          routeWithParams,
          routeTemplate,
        );

        return _RouteInfo(routeName, parameters);
      }
    }

    // Se não encontrou correspondência, retorna como está (rota simples)
    return _RouteInfo(routeWithParams, {});
  }

  // Helper para verificar se uma rota com valores corresponde a um template
  static bool _routeMatches(String routeWithValues, String routeTemplate) {
    final valueParts = routeWithValues.split('/');
    final templateParts = routeTemplate.split('/');

    if (valueParts.length != templateParts.length) {
      return false;
    }

    for (int i = 0; i < templateParts.length; i++) {
      if (!templateParts[i].startsWith(':') &&
          templateParts[i] != valueParts[i]) {
        return false;
      }
    }

    return true;
  }

  // Helper para extrair valores de parâmetros de uma rota com valores
  static Map<String, String> _extractParameterValues(
    String routeWithValues,
    String routeTemplate,
  ) {
    final valueParts = routeWithValues.split('/');
    final templateParts = routeTemplate.split('/');
    final parameters = <String, String>{};

    for (int i = 0; i < templateParts.length && i < valueParts.length; i++) {
      if (templateParts[i].startsWith(':')) {
        final paramName = templateParts[i].substring(1);
        parameters[paramName] = valueParts[i];
      }
    }

    return parameters;
  }

  static void goNamed(String route, {dynamic extra}) {
    final routeInfo = _parseRoute(route);
    _clearStackAndAddRoute(route, routeInfo, extra);

    if (routeInfo.pathParameters.isNotEmpty) {
      goRouter.goNamed(
        routeInfo.routeName,
        pathParameters: routeInfo.pathParameters,
        extra: extra,
      );
    } else {
      goRouter.goNamed(routeInfo.routeName, extra: extra);
    }
  }

  static void pushNamed(String route, {dynamic extra}) {
    final routeInfo = _parseRoute(route);
    _addRouteToStack(route, routeInfo, extra);

    if (routeInfo.pathParameters.isNotEmpty) {
      goRouter.pushNamed(
        routeInfo.routeName,
        pathParameters: routeInfo.pathParameters,
        extra: extra,
      );
    } else {
      goRouter.pushNamed(routeInfo.routeName, extra: extra);
    }
  }

  static void replaceNamed(String route, {dynamic extra}) {
    final routeInfo = _parseRoute(route);
    _replaceCurrentRoute(route, routeInfo, extra);

    if (routeInfo.pathParameters.isNotEmpty) {
      goRouter.replaceNamed(
        routeInfo.routeName,
        pathParameters: routeInfo.pathParameters,
        extra: extra,
      );
    } else {
      goRouter.replaceNamed(routeInfo.routeName, extra: extra);
    }
  }

  static bool canPop() {
    return _navigationStack.length > 1;
  }

  static void pop() {
    try {
      if (canPop()) {
        _removeCurrentRoute();

        final previousEntry = _navigationStack.last;

        if (previousEntry.pathParameters.isNotEmpty) {
          goRouter.goNamed(
            previousEntry.routeName,
            pathParameters: previousEntry.pathParameters,
            extra: previousEntry.extra,
          );
        } else {
          goRouter.goNamed(previousEntry.routeName, extra: previousEntry.extra);
        }
      } else {
        goToHome();
      }
    } catch (e) {
      goToHome();
    }
  }

  static void goToHome() {
    _clearStackAndAddRoute(
      AppRoutes.home,
      _RouteInfo(AppRoutes.home, {}),
      null,
    );
    goRouter.goNamed(AppRoutes.home);
  }

  static void popToHome() {
    try {
      _clearStackAndAddRoute(
        AppRoutes.home,
        _RouteInfo(AppRoutes.home, {}),
        null,
      );
      goRouter.goNamed(AppRoutes.home);
    } catch (e) {
      goToHome();
    }
  }

  static List<String> get currentStack =>
      List.unmodifiable(_navigationStack.map((entry) => entry.originalRoute));

  static String? get currentRoute =>
      _navigationStack.isNotEmpty ? _navigationStack.last.originalRoute : null;

  static void _clearStackAndAddRoute(
    String route,
    _RouteInfo routeInfo,
    dynamic extra,
  ) {
    _navigationStack.clear();
    _navigationStack.add(
      _NavigationEntry(
        originalRoute: route,
        routeName: routeInfo.routeName,
        pathParameters: routeInfo.pathParameters,
        extra: extra,
      ),
    );
  }

  static void _addRouteToStack(
    String route,
    _RouteInfo routeInfo,
    dynamic extra,
  ) {
    _navigationStack.removeWhere((entry) => entry.originalRoute == route);

    if (_navigationStack.isEmpty) {
      _navigationStack.add(
        _NavigationEntry(
          originalRoute: AppRoutes.home,
          routeName: AppRoutes.home,
          pathParameters: {},
        ),
      );
    }

    if (route != AppRoutes.home || _navigationStack.isEmpty) {
      _navigationStack.add(
        _NavigationEntry(
          originalRoute: route,
          routeName: routeInfo.routeName,
          pathParameters: routeInfo.pathParameters,
          extra: extra,
        ),
      );
    }
  }

  static void _replaceCurrentRoute(
    String route,
    _RouteInfo routeInfo,
    dynamic extra,
  ) {
    if (_navigationStack.isNotEmpty) {
      _navigationStack.removeLast();
    }

    if (_navigationStack.isEmpty) {
      _navigationStack.add(
        _NavigationEntry(
          originalRoute: AppRoutes.home,
          routeName: AppRoutes.home,
          pathParameters: {},
        ),
      );
    }

    final lastEntry = _navigationStack.last;
    if (route != lastEntry.originalRoute) {
      _navigationStack.add(
        _NavigationEntry(
          originalRoute: route,
          routeName: routeInfo.routeName,
          pathParameters: routeInfo.pathParameters,
          extra: extra,
        ),
      );
    }
  }

  static void _removeCurrentRoute() {
    if (_navigationStack.isNotEmpty) {
      _navigationStack.removeLast();
    }

    if (_navigationStack.isEmpty) {
      _navigationStack.add(
        _NavigationEntry(
          originalRoute: AppRoutes.home,
          routeName: AppRoutes.home,
          pathParameters: {},
        ),
      );
    }
  }
}
