part of 'async_bloc_scope.dart';

sealed class _FunctionExecutionResult {
  const _FunctionExecutionResult();
}

final class _Success<T> extends _FunctionExecutionResult {
  const _Success(this.data);

  final T data;
}

final class _Failure extends _FunctionExecutionResult {
  const _Failure(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;
}
