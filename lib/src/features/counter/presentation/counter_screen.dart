import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_architecture_starter/src/core/widgets/async_value_ui.dart';
import 'package:riverpod_architecture_starter/src/features/counter/presentation/counter_provider.dart';

/// The main counter screen — demonstrates the full architecture.
///
/// Key pattern with AsyncNotifierProvider:
///   - `ref.watch(counterProvider)` → gets `AsyncValue<Counter>` (data + loading + error)
///   - `ref.read(counterProvider.notifier)` → call mutation methods (increment, decrement)
///
/// No separate FutureProvider needed — the AsyncNotifier handles both!
@RoutePage()
class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Single provider gives us everything: data, loading, and error states
    final counterAsync = ref.watch(counterProvider);

    // Listen for errors and show a snackbar
    ref.listen(
      counterProvider,
      (_, state) => state.showSnackbarOnError(context),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
        actions: [
          // Reset button in the app bar
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: () =>
                ref.read(counterProvider.notifier).reset(),
          ),
        ],
      ),
      body: Center(
        child: counterAsync.when(
          data: (counter) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current Count',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${counter.value}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Increment button
          FloatingActionButton(
            heroTag: 'increment',
            onPressed: () =>
                ref.read(counterProvider.notifier).increment(),
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          // Decrement button
          FloatingActionButton(
            heroTag: 'decrement',
            onPressed: () =>
                ref.read(counterProvider.notifier).decrement(),
            tooltip: 'Decrement',
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}