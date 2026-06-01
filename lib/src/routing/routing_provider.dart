import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_router.dart';

/// Provider for the AppRouter instance.
/// Watch this from the RootAppWidget to configure MaterialApp.router.
final appRouterProvider = Provider<AppRouter>((ref) {
  return AppRouter();
});
