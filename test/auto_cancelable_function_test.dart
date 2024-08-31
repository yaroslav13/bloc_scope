import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_scope/bloc_scope.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';

const _waitDuration = Duration(seconds: 3);

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

const _success = 'success';

final class TestCubit extends Cubit<TestState> with AsyncBlocScope {
  TestCubit() : super(InitialTestState());

  @override
  void onUnhandledError(Object error, StackTrace stackTrace) {
    emit(UnhandledFailureTestState());
  }

  Future<void> onDelayedExceptionTest() async {
    try {
      await autoCancelableFunction(
        _throwExceptionAfterDelay,
      );
    } on Object {
      emit(FailureTestState());
    }
  }

  Future<void> onUnawaitedExceptionTest() async {
    await autoCancelableFunction(
      _throwExceptionAfterUnawaitedDelay,
    );

    //Do something else
    await Future<void>.delayed(
      const Duration(seconds: 3),
      () => emit(
        SuccessTestState(),
      ),
    );
  }

  Future<void> onUnawaitedExceptionAfterFutureCompletesTest() async {
    final result = await autoCancelableFunction(
      _throwUnawaitedExceptionAfterFuncCompletes,
    );

    if (result == _success) {
      emit(SuccessTestState());
    }
  }

  Future<void> onUnawaitedExceptionBeforeFutureCompletesTest() async {
    final result = await autoCancelableFunction(
      _throwUnawaitedExceptionBeforeFuncCompletes,
    );

    if (result == _success) {
      emit(SuccessTestState());
    }
  }

  Future<void> onStateErrorTest() async {
    try {
      await autoCancelableFunction<void>(
        _throwStateError,
      );
    } on Object {
      emit(FailureTestState());
    }
  }

  Future<void> _throwExceptionAfterDelay() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    throw StateError('Something went wrong!');
  }

  Future<void> _throwExceptionAfterUnawaitedDelay() async {
    unawaited(
      Future<void>.delayed(
        const Duration(seconds: 2),
        () => throw Exception(),
      ),
    );
  }

  Future<String> _throwUnawaitedExceptionAfterFuncCompletes() async {
    unawaited(
      Future<void>.delayed(
        const Duration(seconds: 2),
        () => throw Exception(),
      ),
    );

    return Future<String>.delayed(
      const Duration(seconds: 1),
      () => _success,
    );
  }

  Future<String> _throwUnawaitedExceptionBeforeFuncCompletes() async {
    unawaited(
      Future<void>.delayed(
        const Duration(seconds: 1),
        () => throw Exception(),
      ),
    );

    return Future<String>.delayed(
      const Duration(seconds: 3),
      () => _success,
    );
  }

  Future<void> _throwStateError() async {
    throw StateError('state error');
  }
}

void main() {
  blocTest<TestCubit, TestState>(
    '[autoCancelableFunction] test | Process Exception after delay',
    build: TestCubit.new,
    wait: _waitDuration,
    act: (bloc) => unawaited(bloc.onDelayedExceptionTest()),
    expect: () => [
      FailureTestState(),
    ],
  );

  blocTest<TestCubit, TestState>(
    '[autoCancelableFunction] test | Process Exception after unawaited delay',
    build: TestCubit.new,
    wait: _waitDuration,
    act: (bloc) => unawaited(bloc.onUnawaitedExceptionTest()),
    expect: () => [
      UnhandledFailureTestState(),
      SuccessTestState(),
    ],
  );

  blocTest<TestCubit, TestState>(
    '[autoCancelableFunction] test | Process Exception when the first unawaited'
    ' future fails after the second finishes successfully.',
    build: TestCubit.new,
    wait: _waitDuration,
    act: (bloc) => unawaited(
      bloc.onUnawaitedExceptionAfterFutureCompletesTest(),
    ),
    expect: () => [
      SuccessTestState(),
      UnhandledFailureTestState(),
    ],
  );

  blocTest<TestCubit, TestState>(
    '[autoCancelableFunction] test | Process Exception when the first unawaited'
    ' future fails before the second finishes successfully.',
    build: TestCubit.new,
    wait: _waitDuration,
    act: (bloc) => unawaited(
      bloc.onUnawaitedExceptionBeforeFutureCompletesTest(),
    ),
    expect: () => [
      UnhandledFailureTestState(),
      SuccessTestState(),
    ],
  );

  blocTest<TestCubit, TestState>(
    '[autoCancelableFunction] test | Process StateError.',
    build: TestCubit.new,
    wait: _waitDuration,
    act: (bloc) => unawaited(bloc.onStateErrorTest()),
    expect: () => [
      FailureTestState(),
    ],
  );
}
