import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_architecture_starter/src/features/counter/domain/counter.dart';

/// Abstract interface for counter data access.
///
/// The repository abstracts WHERE the counter value comes from.
/// In a real app, this might read from SharedPreferences, a backend, etc.
abstract class CounterRepository {
  Future<Counter> fetchCounter();
  Future<void> saveCounter(Counter counter);
}

/// In-memory fake implementation — perfect for the starter app.
/// Replace with a real implementation (SharedPreferences, API, etc.) as needed.
class FakeCounterRepository implements CounterRepository {
  Counter _counter = const Counter();

  @override
  Future<Counter> fetchCounter() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _counter;
  }

  @override
  Future<void> saveCounter(Counter counter) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    _counter = counter;
  }
}

/// Provider for the counter repository.
/// Override this in main() if you need a different implementation.
final counterRepositoryProvider = Provider<CounterRepository>((ref) {
  return FakeCounterRepository();
});
