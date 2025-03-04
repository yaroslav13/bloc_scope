# AsyncBlocScope

The `AsyncBlocScope` mixin provides enhanced asynchronous handling for Dart's `Bloc` pattern.
It introduces utilities for managing asynchronous operations and subscriptions within a `Bloc`.

## Features

- **Auto-Cancelable Future**: Create async functions that are automatically canceled when the associated `Bloc` is closed. If the future is canceled, it throws an exception.

- **Auto-Cancelable Stream**: Create streams that produces subscriptions that are automatically canceled when the associated `Bloc` is closed.

- **Silent Auto-Cancelable Future**: Create async functions that are automatically canceled when the associated `Bloc` is closed. If the future is canceled, it does not complete, and no exception is thrown.

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

**Note:** In case of `silentAutoCancelableFuture` future will be completed in case of cancellation but the result will be ignored.

### Auto-Cancelable Subscriptions

```dart
final subscriptionController = autoCancelableStream(
 _contactRepository.subscribeForChanges(),
).listen(_onGetsContacts);
```

### Error Handling

Error handling using local zone is available when using `autoCancelableFuture` / `silentAutoCancelableFuture`.
Override the `onUnhandledError` method to handle unhandled errors related to auto-cancelable functions.
