# AsyncBlocScope

The `AsyncBlocScope` mixin provides enhanced asynchronous handling for Dart's `Bloc` pattern.
It introduces utilities for managing asynchronous operations and subscriptions within a `Bloc`.

## Features

- **Auto-Cancelable Future**: Ensures asynchronous functions are automatically canceled when the associated `Bloc` is closed. If canceled, the future throws an exception to indicate termination.
- **Auto-Cancelable Stream**: Create a stream that produces subscriptions that automatically unsubscribe when the associated `Bloc` is closed, preventing memory leaks.
- **Silent Auto-Cancelable Future**: Similar to an auto-cancelable future but without propagating exceptions upon cancellation—allowing for graceful termination without disrupting execution flow.

## Usage

To use `AsyncBlocScope`, simply mixin the `AsyncBlocScope` class in your `Bloc`:

```dart
class MyCubit extends Cubit<MyState> with AsyncBlocScope {
  // Your bloc implementation here
}
```

### Auto-Cancelable/Silent Auto-Cancelable Future

```dart
Future<void> onBound() async {
  try {
    final result = await autoCancelableFuture(() async {
      // Your asynchronous logic here
      return someValue;
    });


    // The result is available here
  } on FutureExecutionInterrupted catch (e) {
    // Handle the exception thrown on cancellation
  }
}

Future<void> onBound() async {
  final result = await silentAutoCancelableFuture(() async {
    // Your asynchronous logic here
    return someValue;
  });
}
```

**Note:** When using `silentAutoCancelableFuture`, if the future is canceled, it completes without returning a result, and no exception is thrown. So it's ignored.

### Auto-Cancelable Subscriptions

```dart
final subscriptionController = autoCancelableStream(
 _contactRepository.subscribeForChanges(),
).listen(_onGetsContacts);
```

### Error Handling

- If an **unhandled exception occurs inside an unawaited future** within `autoCancelableFuture` or `silentAutoCancelableFuture`, it will be **caught by `onUnhandledError` callback**.
- Override the `onUnhandledError` method to manage unhandled exceptions.

