import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_architecture_starter/src/app/root_app_widget.dart';
import 'package:riverpod_architecture_starter/src/core/flavors/flavor.dart';
import 'package:riverpod_architecture_starter/src/core/flavors/flavor_config.dart';

/// Entry point for the app.
///
/// Flutter's --flavor flag sets the global `appFlavor` variable,
/// which is set at compile time when running with --flavor.
///
/// Run with:
///   flutter run --flavor dev     (development)
///   flutter run --flavor prod    (production)
void main() {
  // Use Flutter's built-in appFlavor from --flavor flag
  final flavor = Flavor.values.firstWhere(
    (f) => f.name == appFlavor,
    orElse: () => Flavor.dev,
  );

  _runApp(flavor);
}

/// Common entry point that works for any flavor.
void _runApp(Flavor flavor) {
  // Initialize flavor config before anything else
  FlavorConfig.initialize(flavor);

  runApp(
    ProviderScope(
      child: const RootAppWidget(),
    ),
  );
}