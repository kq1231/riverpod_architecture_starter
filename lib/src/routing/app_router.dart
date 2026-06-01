import 'package:auto_route/auto_route.dart';
import 'package:riverpod_architecture_starter/src/features/counter/presentation/counter_screen.dart';

part 'app_router.gr.dart';

/// Central router configuration for the entire app.
///
/// To add a new route:
///   1. Create your page widget with @RoutePage() annotation
///   2. Add an AutoRoute entry below
///   3. Run: dart run build_runner watch -d
///   4. Use context.router.push(YourRoute()) to navigate
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: CounterRoute.page,
          path: '/',
          initial: true,
        ),
      ];
}
