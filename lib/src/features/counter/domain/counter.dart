/// Immutable counter domain model with pure business logic.
///
/// This is the heart of the counter feature. It knows nothing about
/// Riverpod, repositories, or UI — only how a counter transforms.
class Counter {
  const Counter([this.value = 0]);

  final int value;

  // MARK: - Business Logic

  /// Increment by one
  Counter increment() => Counter(value + 1);

  /// Decrement by one (won't go below zero)
  Counter decrement() => Counter(value > 0 ? value - 1 : 0);

  /// Reset to zero
  Counter reset() => const Counter(0);

  /// Set to a specific value
  Counter setValue(int newValue) => Counter(newValue);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Counter && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Counter($value)';
}
