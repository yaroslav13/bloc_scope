import 'package:meta/meta.dart';

@immutable
abstract base class TestState {}

final class InitialTestState extends TestState {
  @override
  bool operator ==(Object other) => other is InitialTestState;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class FailureTestState extends TestState {
  @override
  bool operator ==(Object other) => other is FailureTestState;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class UnhandledFailureTestState extends TestState {
  @override
  bool operator ==(Object other) => other is UnhandledFailureTestState;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class SuccessTestState extends TestState {
  @override
  bool operator ==(Object other) => other is SuccessTestState;

  @override
  int get hashCode => runtimeType.hashCode;
}
