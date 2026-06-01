import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Centralized app initialization provider.
///
/// All async startup tasks (SharedPreferences, database init, etc.) go here.
/// The AppStartupWidget watches this and shows loading/error/success states.
///
/// To add a new initialization step:
///   1. Create a FutureProvider for the dependency
///   2. Watch it here with ref.watch(yourProvider.future)
///   3. The AppStartupWidget will automatically handle loading/error
final appStartupProvider = FutureProvider<void>((ref) async {
  // Eagerly initialize all async dependencies here.
  // Independent initializations can run in parallel with Future.wait.
  //
  // Example:
  //   await ref.watch(sharedPreferencesProvider.future);
  //
  // For independent deps:
  //   await Future.wait([
  //     ref.watch(sharedPreferencesProvider.future),
  //     ref.watch(databaseProvider.future),
  //   ]);
});
