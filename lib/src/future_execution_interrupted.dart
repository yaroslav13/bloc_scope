import 'package:meta/meta.dart';

/// An exception that is thrown when a function execution is interrupted.
@immutable
final class FutureExecutionInterrupted implements Exception {
  /// Creates a [FutureExecutionInterrupted] exception.
  const FutureExecutionInterrupted();
}
