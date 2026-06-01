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

## Provider vs AsyncNotifierProvider

| | `Provider` (plain) | `AsyncNotifierProvider` |
|---|---|---|
| **Purpose** | Dependency injection (give me the class) | Fetch data + perform mutations + manage UI state |
| **Has methods?** | No — just returns a class instance | Yes — increment(), save(), etc. |
| **When to use** | Repositories, Services | Feature state that widgets watch |

**When you need BOTH fetching AND mutations → use AsyncNotifierProvider.** It replaces the need for a separate FutureProvider + controller combo.

```dart
// Single AsyncNotifier handles both fetching (build) and mutating
class CounterProvider extends AsyncNotifier<Counter> {
  @override
  Future<Counter> build() async => repo.fetchCounter(); // fetch
  Future<void> increment() async { ... }                 // mutate
}
```

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
- **Use `dart analyze`**, not `flutter analyze`
