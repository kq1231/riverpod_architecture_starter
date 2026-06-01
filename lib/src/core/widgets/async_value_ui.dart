import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Extension on AsyncValue to easily show error snackbars from controllers.
///
/// Usage in a ConsumerWidget's build method:
///   `ref.listen<MyState>(myProvider, (_, state) => state.showSnackbarOnError(context))`
extension AsyncValueUI on AsyncValue {
  /// Shows a SnackBar if the async value has an error and is not loading.
  void showSnackbarOnError(BuildContext context) {
    if (!isLoading && hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }
}
