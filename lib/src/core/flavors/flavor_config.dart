import 'package:flutter/material.dart';

import 'flavor.dart';

/// Centralized configuration for the current flavor.
/// Accessed via FlavorConfig.instance throughout the app.
class FlavorConfig {
  FlavorConfig._({required this.flavor});

  /// The singleton instance — set once during app startup
  static late final FlavorConfig instance;

  /// Initialize the config with the given flavor. Called once in main().
  static void initialize(Flavor flavor) {
    instance = FlavorConfig._(flavor: flavor);
  }

  /// The current flavor the app is running in
  final Flavor flavor;

  // Convenience Getters

  bool get isDev => flavor.isDev;
  String get label => flavor.label;
  Color get seedColor => flavor.seedColor;
}