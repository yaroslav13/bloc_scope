part of 'async_bloc_scope.dart';

/// A wrapper around a [Stream] that notifies when a subscription is created.
final class _SubscriptionHookStream<T> implements Stream<T> {
  /// Creates a [_SubscriptionHookStream]
  const _SubscriptionHookStream(
    this._source, {
    required void Function(StreamSubscription<T>) onSubscriptionCreated,
  }) : _onSubscriptionCreated = onSubscriptionCreated;

  final Stream<T> _source;
  final void Function(StreamSubscription<T>) _onSubscriptionCreated;

  /// This method creates a subscription and listens to the stream.
  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final subscription = _source.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );

    _onSubscriptionCreated(subscription);

    return subscription;
  }

  @override
  Future<bool> any(bool Function(T element) test) {
    return _source.any(test);
  }

  @override
  Stream<T> asBroadcastStream({
    void Function(StreamSubscription<T> subscription)? onListen,
    void Function(StreamSubscription<T> subscription)? onCancel,
  }) {
    return _source.asBroadcastStream(
      onListen: onListen,
      onCancel: onCancel,
    );
  }

  @override
  Stream<E> asyncExpand<E>(Stream<E>? Function(T event) convert) {
    return _source.asyncExpand(convert);
  }

  @override
  Stream<E> asyncMap<E>(FutureOr<E> Function(T event) convert) {
    return _source.asyncMap(convert);
  }

  @override
  Stream<R> cast<R>() {
    return _source.cast<R>();
  }

  @override
  Future<bool> contains(Object? needle) {
    return _source.contains(needle);
  }

  @override
  Stream<T> distinct([bool Function(T previous, T next)? equals]) {
    return _source.distinct(equals);
  }

  @override
  Future<E> drain<E>([E? futureValue]) {
    return _source.drain(futureValue);
  }

  @override
  Future<T> elementAt(int index) {
    return _source.elementAt(index);
  }

  @override
  Future<bool> every(bool Function(T element) test) {
    return _source.every(test);
  }

  @override
  Stream<S> expand<S>(Iterable<S> Function(T element) convert) {
    return _source.expand(convert);
  }

  @override
  Future<T> get first => _source.first;

  @override
  Future<T> firstWhere(
    bool Function(T element) test, {
    T Function()? orElse,
  }) {
    return _source.firstWhere(test, orElse: orElse);
  }

  @override
  Future<S> fold<S>(S initialValue, S Function(S previous, T element) combine) {
    return _source.fold(initialValue, combine);
  }

  @override
  Future<void> forEach(void Function(T element) action) {
    return _source.forEach(action);
  }

  @override
  Stream<T> handleError(
    Function onError, {
    bool Function(dynamic error)? test,
  }) {
    return _source.handleError(onError, test: test);
  }

  @override
  bool get isBroadcast => _source.isBroadcast;

  @override
  Future<bool> get isEmpty => _source.isEmpty;

  @override
  Future<String> join([String separator = '']) {
    return _source.join(separator);
  }

  @override
  Future<T> get last => _source.last;

  @override
  Future<T> lastWhere(bool Function(T element) test, {T Function()? orElse}) {
    return _source.lastWhere(test, orElse: orElse);
  }

  @override
  Future<int> get length => _source.length;

  @override
  Stream<S> map<S>(S Function(T event) convert) {
    return _source.map(convert);
  }

  @override
  Future<dynamic> pipe(StreamConsumer<T> streamConsumer) {
    return _source.pipe(streamConsumer);
  }

  @override
  Future<T> reduce(T Function(T previous, T element) combine) {
    return _source.reduce(combine);
  }

  @override
  Future<T> get single => _source.single;

  @override
  Future<T> singleWhere(bool Function(T element) test, {T Function()? orElse}) {
    return _source.singleWhere(test, orElse: orElse);
  }

  @override
  Stream<T> skip(int count) {
    return _source.skip(count);
  }

  @override
  Stream<T> skipWhile(bool Function(T element) test) {
    return _source.skipWhile(test);
  }

  @override
  Stream<T> take(int count) {
    return _source.take(count);
  }

  @override
  Stream<T> takeWhile(bool Function(T element) test) {
    return _source.takeWhile(test);
  }

  @override
  Stream<T> timeout(
    Duration timeLimit, {
    void Function(EventSink<T> sink)? onTimeout,
  }) {
    return _source.timeout(timeLimit, onTimeout: onTimeout);
  }

  @override
  Future<List<T>> toList() {
    return _source.toList();
  }

  @override
  Future<Set<T>> toSet() {
    return _source.toSet();
  }

  @override
  Stream<S> transform<S>(StreamTransformer<T, S> streamTransformer) {
    return _source.transform(streamTransformer);
  }

  @override
  Stream<T> where(bool Function(T event) test) {
    return _source.where(test);
  }
}
