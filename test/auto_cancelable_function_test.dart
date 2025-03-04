import 'dart:async';

import 'package:bloc_test/bloc_test.dart';

import 'cubit/test_cubit.dart';
import 'cubit/test_state.dart';

const _waitDuration = Duration(seconds: 3);

void main() {
  blocTest<TestCubit, TestState>(
    '[autoCancelableFuture] test | Process Exception after delay',
    build: TestCubit.new,
    wait: _waitDuration,
    act: (bloc) => unawaited(bloc.onDelayedExceptionTest()),
    expect: () => [
      FailureTestState(),
    ],
  );

  blocTest<TestCubit, TestState>(
    '[autoCancelableFuture] test | Process Exception after unawaited delay',
    build: TestCubit.new,
    wait: _waitDuration,
    act: (bloc) => unawaited(bloc.onUnawaitedExceptionTest()),
    expect: () => [
      UnhandledFailureTestState(),
      SuccessTestState(),
    ],
  );

  blocTest<TestCubit, TestState>(
    '[autoCancelableFuture] test | Process Exception when the first unawaited'
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
    '[autoCancelableFuture] test | Process Exception when the first unawaited'
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
    '[autoCancelableFuture] test | Process StateError.',
    build: TestCubit.new,
    wait: _waitDuration,
    act: (bloc) => unawaited(bloc.onStateErrorTest()),
    expect: () => [
      FailureTestState(),
    ],
  );
}
