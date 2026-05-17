# otel_sage_intacct

Dartastic OpenTelemetry bridge for Sage Intacct (mid-market financial mgmt).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_sage_intacct/otel_sage_intacct.dart';

await tracedSageIntacct<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return SageIntacctCallResult(value: r, result: SageIntacctResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutSageIntacctInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
