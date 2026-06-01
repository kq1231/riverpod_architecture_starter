import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_architecture_starter/src/core/flavors/flavor.dart';
import 'package:riverpod_architecture_starter/src/core/flavors/flavor_config.dart';
import 'package:riverpod_architecture_starter/src/app/root_app_widget.dart';

void main() {
  testWidgets('App renders counter screen', (tester) async {
    // Initialize flavor config before running the app
    FlavorConfig.initialize(Flavor.dev);

    await tester.pumpWidget(
      const ProviderScope(
        child: RootAppWidget(),
      ),
    );

    // App should show loading during initialization, then the counter
    // Since appStartupProvider resolves immediately (no real async deps),
    // we pump and settle to let it complete
    await tester.pumpAndSettle();

    // Verify the counter screen is visible
    expect(find.text('Current Count'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });
}