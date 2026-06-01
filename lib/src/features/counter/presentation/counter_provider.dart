import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_architecture_starter/src/features/counter/data/counter_repository.dart';
import 'package:riverpod_architecture_starter/src/features/counter/domain/counter.dart';

/// Provider for the Counter feature — handles BOTH fetching and mutating data.
///
/// This follows the Riverpod Architecture pattern where an AsyncNotifierProvider
/// replaces the need for a separate FutureProvider + controller combo.
/// One provider, one class, both concerns.
///
/// The build() method fetches the initial data (like a FutureProvider).
/// Mutation methods (increment, decrement, reset) update the state directly
/// by calling the repository and setting the new value.
///
/// Flow: Widget → Provider → Repository → Domain Model
class CounterProvider extends AsyncNotifier<Counter> {
  @override
  Future<Counter> build() async {
    // Fetches initial data — equivalent to what a FutureProvider would do
    final repo = ref.read(counterRepositoryProvider);
    return repo.fetchCounter();
  }

  // MARK: - Mutation Methods

  /// Increment: fetch current → transform via domain model → save → update state
  Future<void> increment() async {
    final repo = ref.read(counterRepositoryProvider);
    final current = state.value ?? const Counter();
    final updated = current.increment();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.saveCounter(updated);
      return updated;
    });
  }

  /// Decrement: fetch current → transform via domain model → save → update state
  Future<void> decrement() async {
    final repo = ref.read(counterRepositoryProvider);
    final current = state.value ?? const Counter();
    final updated = current.decrement();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.saveCounter(updated);
      return updated;
    });
  }

  /// Reset the counter to zero
  Future<void> reset() async {
    final repo = ref.read(counterRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.saveCounter(const Counter());
      return const Counter();
    });
  }
}

/// Single provider for the counter — handles both data fetching and mutations.
/// Watch this to get the current counter value. Read the notifier to call mutations.
final counterProvider =
    AsyncNotifierProvider<CounterProvider, Counter>(
  CounterProvider.new,
);
