import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_scope/src/async_bloc_scope.dart';

import 'test_state.dart';

const _success = 'success';

final class TestCubit extends Cubit<TestState> with AsyncBlocScope {
  TestCubit() : super(InitialTestState());

  @override
  void onUnhandledError(Object error, StackTrace stackTrace) {
    emit(UnhandledFailureTestState());
  }

  Future<void> onDelayedExceptionTest() async {
    try {
      await autoCancelableFuture(
        _throwExceptionAfterDelay,
      );
    } on Object {
      emit(FailureTestState());
    }
  }

  Future<void> onUnawaitedExceptionTest() async {
    await autoCancelableFuture(
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
    final result = await autoCancelableFuture(
      _throwUnawaitedExceptionAfterFuncCompletes,
    );

    if (result == _success) {
      emit(SuccessTestState());
    }
  }

  Future<void> onUnawaitedExceptionBeforeFutureCompletesTest() async {
    final result = await autoCancelableFuture(
      _throwUnawaitedExceptionBeforeFuncCompletes,
    );

    if (result == _success) {
      emit(SuccessTestState());
    }
  }

  Future<void> onStateErrorTest() async {
    try {
      await autoCancelableFuture<void>(
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
