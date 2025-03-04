part of 'async_bloc_scope.dart';

sealed class _OperationExecutionResult {
  const _OperationExecutionResult();
}

final class _Success<T> extends _OperationExecutionResult {
  const _Success(this.data);

  final T data;
}

final class _Failure extends _OperationExecutionResult {
  const _Failure(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;
}
