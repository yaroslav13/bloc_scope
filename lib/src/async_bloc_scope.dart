import 'dart:async';

import 'package:async/async.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_scope/bloc_scope.dart';
import 'package:bloc_scope/src/future_execution_interrupted.dart';
import 'package:meta/meta.dart';

part 'operation_execution_result.dart';
part 'subscription_hook_stream.dart';

/// An interface of stream that produces auto-cancelable subscriptions.
typedef AutoCancelableStream<T> = _SubscriptionHookStream<T>;

/// A mixin that provides safe asynchronous operations for [BlocBase].
mixin AsyncBlocScope<State> on BlocBase<State> {
  final Set<StreamSubscription<dynamic>> _subscriptions = {};
  final Set<CancelableOperation<dynamic>> _cancelableOperations = {};

  /// [silentAutoCancelableFuture] or [autoCancelableFuture] runs safely
  /// in a zone that catches unhandled errors.
  /// This method is called when an unhandled error is caught.
  /// ignore: no-empty-block
  @protected
  void onUnhandledError(Object error, StackTrace stackTrace) {}

  /// This method crates a [AutoCancelableStream] based on the provided [stream]
  /// The [AutoCancelableStream] is a wrapper around a [Stream] that produces
  /// auto-cancelable subscriptions.
  ///
  /// When you call [AutoCancelableStream.listen], the subscription is created
  /// and added to the [AsyncBlocScope] subscriptions.
  /// When the [AsyncBlocScope] is closed, all subscriptions are canceled.
  ///
  /// When you call [AutoCancelableStream.listen], you also get an instance of
  /// [StreamSubscription] that allows you to pause, resume or cancel
  /// the subscription.
  @protected
  AutoCancelableStream<S> autoCancelableStream<S>(
    Stream<S> stream,
  ) {
    return _SubscriptionHookStream<S>(
      stream,
      onSubscriptionCreated: _subscriptions.add,
    );
  }

  /// Launch a future that would be canceled in case of bloc closing.
  /// If the future is canceled, ignores the future result
  /// and does not throw an error.
  ///
  /// The future continues to take a place in the memory till it completes.
  @protected
  Future<T> silentAutoCancelableFuture<T>(
    Future<T> Function() function,
  ) async {
    return _executeAutoCancelableFuture(
      function,
      ignoreCanceledFuture: true,
    );
  }

  /// Launch a future that would be canceled in case of bloc closing.
  /// If the future is canceled, the [FutureExecutionInterrupted] exception
  /// is thrown.
  ///
  /// You can catch this exception and handle it as needed.
  @protected
  Future<T> autoCancelableFuture<T>(
    Future<T> Function() function,
  ) async {
    return _executeAutoCancelableFuture(function);
  }

  /// Close all subscriptions and cancel all cancelable operations.
  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }

    for (final cancellableOperation in _cancelableOperations) {
      await cancellableOperation.cancel();
    }

    _subscriptions.clear();
    _cancelableOperations.clear();

    await super.close();
  }

  Future<T> _executeAutoCancelableFuture<T>(
    Future<T> Function() function, {
    bool ignoreCanceledFuture = false,
  }) async {
    final completer = CancelableCompleter<_OperationExecutionResult>();

    final completerCancelableOperation = completer.operation;
    _cancelableOperations.add(completerCancelableOperation);

    runZonedGuarded<void>(
      () async {
        try {
          final value = await function();

          completer.complete(_Success(value));
        } on Object catch (e, s) {
          completer.complete(_Failure(e, s));
        }
      },
      onUnhandledError,
    );

    final result = ignoreCanceledFuture
        ? await completerCancelableOperation.value
        : await completerCancelableOperation.valueOrCancellation();

    if (result == null) {
      throw const FutureExecutionInterrupted();
    }

    return switch (result) {
      _Success(data: final data) => data as T,
      //ignore: only_throw_errors
      _Failure(
        error: final error,
        stackTrace: final stackTrace,
      ) =>
        Error.throwWithStackTrace(error, stackTrace),
    };
  }
}
