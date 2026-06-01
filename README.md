# Riverpod Architecture Starter

A Flutter starter app following [Code with Andrea's Riverpod Architecture](https://codewithandrea.com/articles/flutter-app-architecture-riverpod-introduction/). Scaffold new projects with a proven, production-ready architecture.

## Architecture

```
Presentation → Application → Domain ← Data
```

| Layer | Contains | Depends On |
|-------|----------|------------|
| **Presentation** | Widgets, Providers (AsyncNotifier) | Application, Domain |
| **Application** | Services (coordinate multiple repos) | Domain, Data |
| **Domain** | Models + pure business logic | Nothing |
| **Data** | Repositories, DTOs | Domain |

📖 See [ARCHITECTURE.md](ARCHITECTURE.md) for the full reference.

## What's Included

- ✅ **Feature-first project structure** — organized by domain, not UI
- ✅ **Counter feature** as a reference implementation (domain → data → presentation)
- ✅ **Robust app initialization** — loading/error/retry with deep link support
- ✅ **AutoRoute** — declarative routing with code generation
- ✅ **Flavors** — dev & prod via Flutter's `--flavor` flag
- ✅ **No riverpod_generator** — manual providers for simplicity

## Getting Started

### Run the app

```bash
# Development (orange theme, debug banner)
flutter run --flavor dev

# Production (blue theme, no banner)
flutter run --flavor prod
```

### Create a new project from this starter

```bash
# Clone and rename
cp -r riverpod_architecture_starter /path/to/my_new_app
cd /path/to/my_new_app
chmod +x scripts/rename.sh
./scripts/rename.sh com.mycompany.myapp "My App"

# Clean, rebuild, verify
flutter clean
flutter pub get
dart run build_runner build
dart analyze lib/
```

## Adding a New Feature

Follow the counter feature as a template:

```
lib/src/features/my_feature/
├── data/
│   └── my_feature_repository.dart   # Abstract + concrete, returns domain models
├── domain/
│   └── my_model.dart                # Immutable entity + pure business logic
└── presentation/
    ├── my_feature_provider.dart      # AsyncNotifier (fetch + mutate)
    └── my_feature_screen.dart        # @RoutePage() widget
```

1. Create the domain model (pure, no dependencies)
2. Create the repository (converts DTOs → models)
3. Create the AsyncNotifier provider (fetches + mutates)
4. Create the screen with `@RoutePage()`
5. Register the route in `AppRouter`
6. Run `dart run build_runner build`

## Where Does Business Logic Go?

**Push logic DOWN as far as it can go:**

1. **Domain Model** — pure transformations (`counter.increment()`)
2. **Service** — logic spanning multiple repos (only when needed)
3. **Provider** — simple mutations using one repo

## KIF Integration

This project includes [KifDiff](https://github.com/kif-diff/kif_diff) skills and rules:

| Type | File | Purpose |
|------|------|---------|
| Rule | `.kif/rules/read_architecture.md` | Auto-read ARCHITECTURE.md at conversation start |
| Skill | `.kif/skills/flavors/` | Add/remove flavor configurations |
| Skill | `.kif/skills/rename-starter/` | Clone and rename the starter app |
| Skill | `.kif/skills/auto-route/` | AutoRoute patterns and usage guide |

## License

MIT