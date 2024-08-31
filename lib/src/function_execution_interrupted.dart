import 'package:flutter/foundation.dart';

/// An exception that is thrown when a function execution is interrupted.
@immutable
final class FunctionExecutionInterrupted implements Exception {
  /// Creates a [FunctionExecutionInterrupted] exception.
  const FunctionExecutionInterrupted();
}
