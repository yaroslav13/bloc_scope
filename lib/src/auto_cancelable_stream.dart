import 'dart:async';

/// A wrapper around a [Stream] that notifies when a subscription is created.
final class AutoCancelableStream<T> {
  /// Creates a [AutoCancelableStream]
  const AutoCancelableStream(
    this._source, {
    required void Function(StreamSubscription<T>) onSubscriptionCreated,
  }) : _onSubscriptionCreated = onSubscriptionCreated;

  final Stream<T> _source;
  final void Function(StreamSubscription<T>) _onSubscriptionCreated;

  /// This method creates a subscription and listens to the stream.
  StreamSubscription<T> listen(
    void Function(T data)? handleData, {
    void Function(Object, StackTrace)? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final subscription = _source.listen(
      handleData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );

    _onSubscriptionCreated(subscription);

    return subscription;
  }
}
