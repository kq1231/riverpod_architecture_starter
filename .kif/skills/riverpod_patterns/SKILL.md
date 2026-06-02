---
name: riverpod_patterns
description: "Riverpod provider patterns and anti-patterns — choosing the right provider type."
triggers:
  - provider
  - notifier
  - async notifier
  - stream notifier
  - controller
  - riverpod pattern
  - add provider
  - create provider
  - state management
tools_required:
  - "@Kif READ"
  - "@Kif SEARCH_AND_REPLACE"
tags: [riverpod, providers, state management, patterns]
---

# Riverpod Provider Patterns

## Choosing the Right Provider

Ask two questions:
1. **Is the data synchronous or asynchronous?**
2. **Do you only provide data, or also mutate it?**

| Need | Sync, read-only | Sync, read-write | Async, read-only | Async, read-write | Stream, read-only | Stream, read-write |
|------|:---:|:---:|:---:|:---:|:---:|:---:|
| **Use** | `Provider` | `NotifierProvider` | `FutureProvider` | `AsyncNotifierProvider` | `StreamProvider` | `StreamNotifierProvider` |

## Common Patterns in This Project

### AsyncNotifierProvider (most common for features)

Use when: you fetch data AND have methods to mutate it.

```dart
class CounterProvider extends AsyncNotifier<Counter> {
  @override
  Future<Counter> build() async {
    final repo = ref.read(counterRepositoryProvider);
    return repo.fetchCounter();
  }

  Future<void> increment() async {
    final repo = ref.read(counterRepositoryProvider);
    final current = await repo.fetchCounter();
    await repo.setCounter(current.increment());
    ref.invalidateSelf();
  }
}

final counterProvider =
    AsyncNotifierProvider<CounterProvider, Counter>(CounterProvider.new);
```

### Provider (for DI)

Use when: providing a dependency (repository, service) with no methods.

```dart
final counterRepositoryProvider = Provider<CounterRepository>((ref) {
  return CounterRepositoryImpl();
});
```

### Controller (for UI operations without data)

Use when: triggering an async operation from UI, showing loading state, but NOT providing data.

```dart
class SubmitOrderController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> submit(Order order) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repo.submitOrder(order));
  }
}
```

## Anti-Patterns

### ❌ NEVER split a Notifier into Provider + Controller class

```dart
// WRONG — old Provider/BLoC pattern leaking into Riverpod
final counterProvider = FutureProvider<Counter>((ref) => repo.fetchCounter());

class CounterController {  // This class should NOT exist separately
  CounterController(this.ref);
  final Ref ref;
  Future<void> increment() async { ... }
}
```

**Why it's wrong:**
- Breaks `ref.watch` — the controller can't auto-refresh when state changes
- Defeats Riverpod's design — state and methods belong together in a Notifier
- Makes testing harder — two things to mock instead of one
- This is the old `ChangeNotifier` / BLoC pattern — Riverpod doesn't need it

**Instead, use AsyncNotifierProvider with methods:**

```dart
// CORRECT — state and methods together
class CounterProvider extends AsyncNotifier<Counter> {
  @override
  Future<Counter> build() async => repo.fetchCounter();
  Future<void> increment() async { ... }
}
```

### ❌ NEVER use riverpod_generator

This project uses manual providers only. No `@riverpod` annotations, no code generation for providers.

## Widget Types for Accessing Providers

### ConsumerWidget (most common)

Like `StatelessWidget` but with `ref`. Use this for most of your widgets.

```dart
class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counterAsync = ref.watch(counterProvider);

    return counterAsync.when(
      data: (counter) => Text('${counter.value}'),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text(e.toString()),
    );
  }
}
```

### ConsumerStatefulWidget

Like `StatefulWidget` but with `ref`. Use when you need providers AND local widget state (TextEditingController, AnimationController, ScrollController, etc.).

```dart
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController(); // local state

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchProvider(_searchController.text)); // + providers
    return ...;
  }
}
```

### Consumer (scoped rebuilds)

A widget you place INSIDE an existing widget tree to get `ref` for just a subtree. Use when you want only a small part of the widget to rebuild when a provider changes — not the entire widget.

```dart
class MyPage extends StatelessWidget {
  // No ref needed at this level
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('This part never rebuilds'),
        // Only this Consumer rebuilds when counterProvider changes
        Consumer(
          builder: (context, ref, child) {
            final counter = ref.watch(counterProvider);
            return Text('Count: ${counter.value}');
          },
        ),
        const Text('This part also never rebuilds'),
      ],
    );
  }
}
```

**When to use which:**
- **ConsumerWidget** — default choice, 90% of the time
- **ConsumerStatefulWidget** — only when you need local state (controllers, focus nodes)
- **Consumer** — when you want to minimize rebuilds by scoping `ref.watch` to a subtree

## Accessing Providers

```dart
// Watch for rebuilds (in build method)
final counterAsync = ref.watch(counterProvider);

// Read without rebuilding (inside methods/callbacks)
final repo = ref.read(counterRepositoryProvider);

// Listen for side effects (snackbars, navigation)
ref.listen(counterProvider, (prev, next) { ... });
```
