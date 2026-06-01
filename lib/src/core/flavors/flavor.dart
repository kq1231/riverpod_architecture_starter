import 'package:flutter/material.dart';

/// Represents the different environments the app can run in.
/// Each flavor has its own configuration for API endpoints, feature flags, etc.
enum Flavor {
  dev,
  prod;

  /// Human-readable label for the flavor
  String get label => switch (this) {
        dev => 'DEV',
        prod => 'PROD',
      };

  /// Theme seed color per flavor — makes it visually obvious which env you're in
  Color get seedColor => switch (this) {
        dev => Colors.orange,
        prod => Colors.blue,
      };

  /// Whether this flavor shows debug banners and dev-only features
  bool get isDev => this == dev;
}
