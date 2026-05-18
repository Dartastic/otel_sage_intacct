// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_sage_intacct/otel_sage_intacct.dart';
import 'package:test/test.dart';

void main() {
  group('otel_sage_intacct', () {
    test('suppression toggles in zone', () async {
      expect(sageIntacctInstrumentationSuppressed(), isFalse);
      await runWithoutSageIntacctInstrumentationAsync(() async {
        expect(sageIntacctInstrumentationSuppressed(), isTrue);
      });
      expect(sageIntacctInstrumentationSuppressed(), isFalse);
    });

    test('SageIntacctResult fields default null', () {
      const r = SageIntacctResult();
      expect(r.statusCode, isNull);
    });
  });
}
