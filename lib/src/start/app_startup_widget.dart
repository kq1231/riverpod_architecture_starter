import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_startup_provider.dart';

/// Manages the app's asynchronous initialization flow.
///
/// Shows three states:
///   - Loading → AppStartupLoadingWidget (matches native splash for seamless feel)
///   - Error   → AppStartupErrorWidget (with retry button)
///   - Success → The onLoaded callback (the router's child — main app UI)
///
/// ## Why this lives inside MaterialApp.builder
///
/// This widget is NOT wrapped in its own MaterialApp — it's placed inside
/// `MaterialApp.router(builder:)` so that:
///   1. There's only ONE MaterialApp in the tree (no double-navigator issues)
///   2. The router is alive from the first frame (deep links work)
///   3. This widget just conditionally swaps children until init completes
///
/// The widget tree is always:
/// ```
/// MaterialApp.router
///   └── this widget
///         └── loading OR error OR router's child
/// ```
/// Never a separate MaterialApp for each state.
class AppStartupWidget extends ConsumerWidget {
  const AppStartupWidget({super.key, required this.onLoaded});

  /// Called when initialization succeeds — renders the main app.
  /// In practice, this returns the router's `child` that was passed
  /// through MaterialApp.builder.
  final WidgetBuilder onLoaded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupState = ref.watch(appStartupProvider);
    return startupState.when(
      loading: () => const AppStartupLoadingWidget(),
      error: (e, st) => AppStartupErrorWidget(
        message: e.toString(),
        // Invalidating the provider triggers re-initialization (retry).
        // All providers that appStartupProvider depends on are also
        // invalidated via their ref.onDispose callbacks.
        onRetry: () => ref.invalidate(appStartupProvider),
      ),
      data: (_) => onLoaded(context),
    );
  }
}

/// Loading screen shown during app initialization.
///
/// Matches the native splash screen for a seamless transition.
/// Since we're already inside MaterialApp, Scaffold and theme work naturally.
class AppStartupLoadingWidget extends StatelessWidget {
  const AppStartupLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Error screen with retry button shown when initialization fails.
///
/// Gives the user a way to recover instead of being stuck on a blank screen.
/// Since we're already inside MaterialApp, we get theme and Scaffold for free.
class AppStartupErrorWidget extends StatelessWidget {
  const AppStartupErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}