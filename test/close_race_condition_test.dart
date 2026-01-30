import 'dart:async';

import 'package:bloc_scope/src/future_execution_interrupted.dart';
import 'package:test/test.dart';

import 'cubit/test_cubit.dart';

void main() {
  group('AsyncBlocScope close() race condition tests', () {
    test('close() prevents new futures from being started', () async {
      final cubit = TestCubit();
      
      // Close the cubit first
      await cubit.close();
      
      // Try to start a new future after close - should throw StateError
      await expectLater(
        cubit.autoCancelableFuture(() async => 'test'),
        throwsStateError,
      );
    });

    test('close() prevents new streams from being created', () async {
      final cubit = TestCubit();
      
      // Create a stream
      final stream1 = cubit.autoCancelableStream(
        Stream.fromIterable([1, 2, 3]),
      );
      stream1.listen((_) {});
      
      // Close the cubit
      await cubit.close();
      
      // Try to create a new stream after close - should throw StateError
      expect(
        () => cubit.autoCancelableStream(Stream.fromIterable([4, 5, 6])),
        throwsStateError,
      );
    });

    test(
      'close() cancels all operations and throws FutureExecutionInterrupted',
      () async {
        final cubit = TestCubit();
        
        // Start a future
        final future1 = cubit.autoCancelableFuture(() async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return 'result1';
        });
        
        // Give future a moment to start
        await Future<void>.delayed(const Duration(milliseconds: 10));
        
        // Close the cubit - this should cancel the future
        unawaited(cubit.close());
        
        // Future should throw FutureExecutionInterrupted
        await expectLater(
          future1,
          throwsA(isA<FutureExecutionInterrupted>()),
        );
      },
    );

    test(
      'close() cancels multiple operations in parallel',
      () async {
        final cubit = TestCubit();
        
        // Start multiple futures
        final future1 = cubit.autoCancelableFuture(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return 'result1';
        });
        
        final future2 = cubit.autoCancelableFuture(() async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return 'result2';
        });
        
        final future3 = cubit.autoCancelableFuture(() async {
          await Future<void>.delayed(const Duration(milliseconds: 150));
          return 'result3';
        });
        
        // Give futures a moment to start
        await Future<void>.delayed(const Duration(milliseconds: 10));
        
        // Close the cubit - don't await to avoid blocking on sequential cancellation
        final closeFuture = cubit.close();
        
        // All futures should throw FutureExecutionInterrupted
        await expectLater(
          Future.wait([future1, future2, future3]),
          throwsA(isA<FutureExecutionInterrupted>()),
        );
        
        // Now await the close to ensure cleanup completes
        await closeFuture;
      },
    );

    test(
      'close() prevents nested futures from starting '
      'when parent completes during close',
      () async {
        final cubit = TestCubit();
        var nestedFutureStarted = false;
        
        // Start a parent future that will try to trigger nested futures
        final parentFuture = cubit.autoCancelableFuture(() async {
          // Simulate fetch1() from the issue example
          await Future<void>.delayed(const Duration(milliseconds: 50));
          
          // Try to start nested future (fetch2 from the issue)
          // This should fail because close() will be called
          try {
            await cubit.autoCancelableFuture(() async {
              nestedFutureStarted = true;
              await Future<void>.delayed(const Duration(milliseconds: 50));
              return 'nested result';
            });
          } catch (e) {
            // Expected - either StateError or FutureExecutionInterrupted
          }
          
          return 'parent result';
        });
        
        // Give the parent future time to start
        await Future<void>.delayed(const Duration(milliseconds: 10));
        
        // Close the cubit while parent is running - don't await yet
        final closeFuture = cubit.close();
        
        // Parent should be interrupted - await it with expectation
        await expectLater(
          parentFuture,
          throwsA(isA<FutureExecutionInterrupted>()),
        );
        
        // Now await close
        await closeFuture;
        
        // Wait for everything to settle
        await Future<void>.delayed(const Duration(milliseconds: 100));
        
        // The nested future should NOT have been created after close
        expect(nestedFutureStarted, isFalse);
      },
    );

    test('silentAutoCancelableFuture also respects close', () async {
      final cubit = TestCubit();
      
      // Start a silent future - don't await it yet
      final firstFuture = cubit.silentAutoCancelableFuture(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      
      // Close the cubit
      await cubit.close();
      
      // The first future will hang when canceled with ignoreCanceledFuture
      // We don't need to wait for it - just verify new futures are rejected
      
      // Try to start a new silent future after close - should throw StateError
      await expectLater(
        cubit.silentAutoCancelableFuture(() async => 'second'),
        throwsStateError,
      );
    });

    test('multiple streams are canceled in parallel', () async {
      final cubit = TestCubit();
      final receivedValues = <int>[];
      
      // Create multiple streams that emit values over time
      final stream1 = cubit.autoCancelableStream(
        Stream.periodic(
          const Duration(milliseconds: 50),
          (i) => i,
        ).take(10),
      );
      
      final stream2 = cubit.autoCancelableStream(
        Stream.periodic(
          const Duration(milliseconds: 50),
          (i) => i + 100,
        ).take(10),
      );
      
      final stream3 = cubit.autoCancelableStream(
        Stream.periodic(
          const Duration(milliseconds: 50),
          (i) => i + 200,
        ).take(10),
      );
      
      // Subscribe to all streams
      stream1.listen(receivedValues.add);
      stream2.listen(receivedValues.add);
      stream3.listen(receivedValues.add);
      
      // Let streams emit a few values
      await Future<void>.delayed(const Duration(milliseconds: 120));
      
      // Close the cubit - should cancel all streams
      await cubit.close();
      
      final valuesReceivedBeforeClose = receivedValues.length;
      
      // Wait some more time
      await Future<void>.delayed(const Duration(milliseconds: 200));
      
      // No new values should have been received after close
      expect(receivedValues.length, equals(valuesReceivedBeforeClose));
      
      // We should have received only a few values (not all 30)
      expect(receivedValues.length, lessThan(15));
    });
  });
}
