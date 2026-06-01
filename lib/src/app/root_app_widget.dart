import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_architecture_starter/src/core/flavors/flavor_config.dart';
import 'package:riverpod_architecture_starter/src/routing/routing_provider.dart';
import 'package:riverpod_architecture_starter/src/start/app_startup_widget.dart';

/// Root widget that configures the router and handles app startup.
///
/// This follows Andrea's pattern for supporting URL navigation and deep links.
///
/// ## Why this pattern matters for deep links
///
/// Imagine a user clicks `myapp://products/123` when the app is closed.
/// The OS launches the app, and Flutter must IMMEDIATELY route to `/products/123`.
/// But app startup (SharedPreferences, database, etc.) hasn't finished yet!
///
/// The naive approach (creating the router only AFTER init completes) loses
/// the deep link because the router didn't exist when the OS sent the URL.
///
/// The correct approach (this pattern):
///   1. MaterialApp.router is created IMMEDIATELY in the first frame
///   2. The router is alive and can process deep links from the start
///   3. AppStartupWidget holds back the router's child until init completes
///   4. Once ready, the router's child is released — deep link preserved!
///
/// ## How the builder works
///
/// `MaterialApp.router(builder:)` gives you the router's rendered output:
///   - For URL '/' → child = CounterScreen
///   - For URL '/products/123' → child = ProductScreen(id: 123)
///   - The child is ALWAYS the correct screen for the current URL
///
/// We wrap it with AppStartupWidget to hold it back during initialization.
///
/// ## Widget tree during loading (deep link received):
/// ```
/// ProviderScope
///   └── RootAppWidget
///         └── MaterialApp.router        ← Router is ALIVE, matched the deep link
///               └── builder(context, ProductScreen(id: 123))  ← Router decided
///                     └── AppStartupWidget
///                           └── AppStartupLoadingWidget        ← User sees spinner
/// ```
///
/// ## Widget tree after initialization completes:
/// ```
/// ProviderScope
///   └── RootAppWidget
///         └── MaterialApp.router
///               └── builder(context, ProductScreen(id: 123))
///                     └── AppStartupWidget
///                           └── ProductScreen(id: 123)  ← Deep link works!
/// ```
class RootAppWidget extends ConsumerWidget {
  const RootAppWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.read(appRouterProvider);
    final flavorConfig = FlavorConfig.instance;

    return MaterialApp.router(
      title: 'Riverpod Architecture Starter',
      debugShowCheckedModeBanner: flavorConfig.isDev,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: flavorConfig.seedColor,
        ),
        useMaterial3: true,
      ),
      routerConfig: appRouter.config(),
      // The builder lets us intercept the router's output before it renders.
      // `child` = the screen the router wants to show (based on current URL).
      // We wrap it with AppStartupWidget so initialization completes first.
      // This means the router processes deep links immediately, but the
      // actual screen rendering is deferred until startup is done.
      builder: (_, child) {
        return AppStartupWidget(
          // Once initialization succeeds, release the router's child.
          // The router has already matched the URL — we just show it now.
          onLoaded: (_) => child!,
        );
      },
    );
  }
}