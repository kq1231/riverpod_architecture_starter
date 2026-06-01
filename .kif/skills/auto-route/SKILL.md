---
name: auto_route
description: "Guide for using AutoRoute in this project — adding routes, navigation, guards, and nested routes."
triggers:
  - add route
  - new route
  - navigation
  - auto route
  - autoroute
  - deep link
  - route guard
  - nested route
tools_required:
  - "@Kif READ"
  - "@Kif SEARCH_AND_REPLACE"
  - "@Kif CREATE"
  - "@Kif RUN"
tags: [routing, navigation, autoroute, deep-links]
---

# AutoRoute Skill

## Overview

This project uses [AutoRoute](https://pub.dev/packages/auto_route) for declarative routing with code generation. The router is configured in `lib/src/routing/app_router.dart` and provided via Riverpod.

## Adding a New Route

### 1. Create your page widget with `@RoutePage()` annotation

```dart
// lib/src/features/products/presentation/product_screen.dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Products')));
  }
}
```

### 2. Register the route in AppRouter

```dart
// lib/src/routing/app_router.dart
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: CounterRoute.page, path: '/', initial: true),
    AutoRoute(page: ProductRoute.page, path: '/products'),  // NEW
  ];
}
```

### 3. Run code generation

```bash
dart run build_runner watch -d
```

Or for a one-time build:

```bash
dart run build_runner build
```

### 4. Navigate to the route

```dart
// From any ConsumerWidget:
context.router.push(const ProductRoute());

// Or replace the current route:
context.router.replace(const ProductRoute());
```

## Passing Arguments

### 1. Add parameters to the page widget

```dart
@RoutePage()
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({
    super.key,
    @PathParam('id') required this.productId,
  });

  final String productId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text('Product: $productId'));
  }
}
```

### 2. The generated route will include the parameter

```dart
// Navigate with arguments:
context.router.push(ProductDetailRoute(productId: '123'));

// Deep link: /products/123
AutoRoute(page: ProductDetailRoute.page, path: '/products/:id'),
```

## Route Guards (Auth Protection)

### 1. Create a guard

```dart
import 'package:auto_route/auto_route.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    // Check if user is authenticated
    final isAuthenticated = /* your auth check */;
    if (isAuthenticated) {
      resolver.next(true); // Allow navigation
    } else {
      resolver.redirect(const LoginRoute()); // Redirect to login
    }
  }
}
```

### 2. Apply the guard to a route

```dart
AutoRoute(
  page: ProfileRoute.page,
  path: '/profile',
  guards: [AuthGuard()],  // Protected route
),
```

## Nested Routes (Tab Navigation)

### 1. Create a wrapper page with `AutoRouterWidget`

```dart
@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoRouter(builder: (_, child) {
      return Scaffold(
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          onTap: (index) => context.router.navigate([
            const HomeTabRoute(),
            const ProfileTabRoute(),
          ][index]),
        ),
      );
    });
  }
}
```

### 2. Define nested routes

```dart
AutoRoute(
  page: HomeRoute.page,
  path: '/home',
  children: [
    AutoRoute(page: HomeTabRoute.page, path: 'tab'),
    AutoRoute(page: ProfileTabRoute.page, path: 'profile'),
  ],
),
```

## Navigation Methods

| Method | Description |
|--------|-------------|
| `context.router.push(Route())` | Push a route onto the stack |
| `context.router.replace(Route())` | Replace current route |
| `context.router.pushPath('/products')` | Navigate by path string |
| `context.router.maybePop()` | Pop the current route |
| `context.router.navigateTo(Route())` | Navigate to a route (removes intervening routes) |

## Gotchas

- Always run `dart run build_runner build` after adding/modifying routes
- The generated file is `app_router.gr.dart` (NOT `.g.dart`)
- Use `part 'app_router.gr.dart'` in the router file (NOT `import`)
- `@RoutePage()` must be on the page widget class, NOT the provider
- Route parameters use `@PathParam()` for URL segments, `@QueryParam()` for URL parameters
- The router provider lives in `lib/src/routing/routing_provider.dart`
- Deep links work because the router is initialized in the first frame via `MaterialApp.router`

## File Locations

| File | Purpose |
|------|---------|
| `lib/src/routing/app_router.dart` | Route definitions |
| `lib/src/routing/app_router.gr.dart` | Generated routes (do not edit) |
| `lib/src/routing/routing_provider.dart` | Riverpod provider for the router |
| `lib/src/app/root_app_widget.dart` | MaterialApp.router setup |
