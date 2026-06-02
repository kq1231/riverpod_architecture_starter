# Riverpod Architecture — Quick Reference

Based on [Code with Andrea's Riverpod Architecture](https://codewithandrea.com/articles/flutter-app-architecture-riverpod-introduction/).

## Layers

```
Presentation → Application → Domain ← Data
```

| Layer | Contains | Depends On |
|-------|----------|------------|
| **Presentation** | Widgets, Providers (AsyncNotifier) | Application, Domain |
| **Application** | Services (coordinate multiple repos) | Domain, Data |
| **Domain** | Models + pure business logic | Nothing (zero dependencies) |
| **Data** | Repositories, DTOs | Domain (returns domain models) |

## Where Does Business Logic Go?

**Push logic DOWN as far as it can go:**

1. **Domain Model** — Pure transformations with zero dependencies
   - Example: `counter.increment()`, `cart.addItem()`
   - Easiest to test, no mocking needed

2. **Service (Application Layer)** — Logic spanning multiple repositories
   - Example: `CartService.addItem()` picks local vs remote repo based on auth state
   - Only create when needed. If provider→repo is direct, skip the service.

3. **Provider (Presentation Layer)** — Simple mutations using one repo
   - Example: `CounterProvider.increment()` → fetch → transform → save
   - Keeps widget stateless. Manages loading/error/data via AsyncValue.

## Riverpod Provider Taxonomy

Riverpod has 6 provider types, organized by sync/async and read-only vs read-write:

### Synchronous (value is immediately available)

| Provider | Purpose | Has methods? | Example |
|----------|---------|:---:|---------|
| `Provider` | Provide a value (DI) | No | `themeProvider`, `repoProvider` |
| `NotifierProvider` | Mutable synchronous state with methods | Yes | `TabNotifier` with `selectTab()` |

### Asynchronous (value resolves from a Future/Stream)

| Provider | Purpose | Has methods? | Example |
|----------|---------|:---:|---------|
| `FutureProvider` | Provide async data (read-only after resolve) | No | `configProvider` from shared prefs |
| `AsyncNotifierProvider` | Async state + methods (fetch + mutate) | Yes | `CounterProvider` with `increment()` |
| `StreamProvider` | Provide a stream (read-only) | No | `authStateProvider` from FirebaseAuth |
| `StreamNotifierProvider` | Stream state + methods (listen + mutate) | Yes | `ChatNotifier` with `sendMessage()` |

**The rule:** If you only need to PROVIDE data → use the base version (Provider, FutureProvider, StreamProvider). If you also need to MUTATE or perform side effects → use the Notifier version (NotifierProvider, AsyncNotifierProvider, StreamNotifierProvider).

```dart
// AsyncNotifierProvider — fetch (build) + mutate (methods)
class CounterProvider extends AsyncNotifier<Counter> {
  @override
  Future<Counter> build() async => repo.fetchCounter(); // fetch
  Future<void> increment() async { ... }                 // mutate
}

// NotifierProvider — synchronous state + methods
class TabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void selectTab(int index) => state = index;
}

// StreamNotifierProvider — listen to stream + methods
class ChatNotifier extends StreamNotifier<List<Message>> {
  @override
  Stream<List<Message>> build() => repo.watchMessages();
  Future<void> sendMessage(String text) async { ... }
}
```

### Anti-Pattern: Splitting Provider + Controller

**❌ WRONG — Never split a Notifier into a Provider + separate controller class:**

```dart
// DON'T DO THIS — this is the old Provider/BLoC pattern leaking into Riverpod
final counterProvider = FutureProvider<Counter>((ref) => repo.fetchCounter());

class CounterController {
  CounterController(this.ref);
  final Ref ref;
  Future<void> increment() async { ... }  // methods live outside the provider
}
```

**✅ CORRECT — Use a Notifier that combines state + methods:**

```dart
// DO THIS — state and methods live together in one provider
class CounterProvider extends AsyncNotifier<Counter> {
  @override
  Future<Counter> build() async => repo.fetchCounter();
  Future<void> increment() async { ... }  // methods are part of the provider
}
```

**Why?** Riverpod's design puts state and mutations together. Splitting them breaks `ref.watch` (the controller can't auto-refresh), makes testing harder, and defeats the purpose of the Notifier pattern.

### When to Use a Controller

Controllers DO exist in Riverpod, but only for a specific case: **controlling UI without providing data**.

Use a `Notifier` (without a value) when you need to:
- Perform an async operation triggered by a button
- Show loading/error state for that specific operation
- NOT expose any data that other widgets watch

```dart
// Controller — no data provided, just UI state for an operation
class SubmitOrderController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> submit(Order order) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repo.submitOrder(order));
  }
}

final submitOrderControllerProvider =
    NotifierProvider<SubmitOrderController, AsyncValue<void>>(
  SubmitOrderController.new,
);
```

The key difference: a Controller's state type is `AsyncValue<void>` — it tracks whether an operation is loading/succeeded/failed, but doesn't provide data that other widgets subscribe to.
## Key Classes

| Term | Role | Layer |
|------|------|-------|
| **Model** | Immutable entity with business logic | Domain |
| **DTO** | Raw data shape from API (Map/JSON) | Data (inside repository) |
| **Repository** | Converts DTOs → Models, talks to one data source | Data |
| **Service** | Coordinates multiple repositories | Application |
| **Provider** | Manages widget state for mutations | Presentation |

## Data Sources

In this architecture, "data source" means the **external package** consumed inside a repository (`http.Client`, `FirebaseFirestore.instance`), NOT a separate class. The repository absorbs the data source directly.

## Project Structure

```
lib/
  main.dart
  src/
    app/              # RootAppWidget
    core/
      flavors/        # Flavor enum, FlavorConfig
      widgets/        # Shared widgets (AsyncValueUI extension)
    features/
      counter/
        data/         # Repository (abstract + concrete)
        domain/       # Model (Counter) + pure business logic
        presentation/ # Provider (AsyncNotifier) + Screen widget
    routing/          # AppRouter (AutoRoute)
    start/            # appStartupProvider, AppStartupWidget
```

Feature-first based on **domain**, not UI. Each feature folder is a functional requirement.

## App Initialization

Follows Andrea's robust startup pattern:
1. `RootAppWidget` creates `MaterialApp.router` (router ready for deep links)
2. `AppStartupWidget` wraps router child in `MaterialApp.builder`
3. `appStartupProvider` eagerly initializes all async deps
4. Shows loading/error/retry before main app loads
5. After init, use `requireValue` to access eagerly-initialized providers

## Flavors

Two flavors: **dev** (orange theme, debug banner) and **prod** (blue theme, no banner).

```bash
flutter run --flavor dev
flutter run --flavor prod
```

Uses Flutter's built-in `appFlavor` variable → `FlavorConfig` singleton.

Native platform configs (Android productFlavors, iOS schemes + xcconfigs) are generated by [flutter_flavorizr](https://pub.dev/packages/flutter_flavorizr). Configuration lives in `flavorizr.yaml` at the project root.

To regenerate native configs after changing flavors:
```bash
dart run flutter_flavorizr -p assets:download,assets:extract,android:androidManifest,android:flavorizrGradle,android:buildGradle,android:dummyAssets,ios:xcconfig,ios:buildTargets,ios:schema,ios:dummyAssets,ios:plist,ios:launchScreen,assets:clean -f
```


## Widget Types

| Widget | Like | Use When |
|--------|------|----------|
| **ConsumerWidget** | StatelessWidget + ref | Default choice — most widgets |
| **ConsumerStatefulWidget** | StatefulWidget + ref | Need providers AND local state (controllers) |
| **Consumer** | Inline ref scope | Only a subtree should rebuild |

**Prefer `ConsumerWidget`** for almost everything. Use `ConsumerStatefulWidget` only when you need local mutable state (TextEditingController, etc.). Use `Consumer` inside a larger widget when only a small part should rebuild on provider changes.

## Routing (AutoRoute)

1. Annotate page with `@RoutePage()`
2. Add `AutoRoute(page: YourRoute.page)` in `AppRouter`
3. Run `dart run build_runner watch -d`
4. Navigate: `context.router.push(YourRoute())`

## Rules

- **No riverpod_generator** — manual providers only
- **AutoRoute code-gen is fine** — route generation is separate from Riverpod
- **Models are immutable** — mutations return new instances
- **Repositories return domain models**, not raw JSON
- **Services are optional** — only when coordinating multiple repos
- **Never split a Notifier into Provider + Controller** — state and methods belong together
- **Use Controllers only for UI operations without data** — state type is `AsyncValue<void>`
- **Use `dart analyze`**, not `flutter analyze`
