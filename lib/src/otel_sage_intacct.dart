// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_sage_intacct_suppression.dart';

class SageIntacctResult {
  const SageIntacctResult({
    this.companyId,
    this.entityId,
    this.moduleName,
    this.recordType,
    this.recordId,
    this.amount,
    this.currency,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? companyId;
  final String? entityId;
  final String? moduleName;
  final String? recordType;
  final String? recordId;
  final double? amount;
  final String? currency;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class SageIntacctCallResult<T> {
  const SageIntacctCallResult({required this.value, this.result});
  final T value;
  final SageIntacctResult? result;
}

Future<T> tracedSageIntacct<T>({
  required String operation,
  required Future<SageIntacctCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (sageIntacctInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_sage_intacct');
  final span = t.startSpan('sageintacct $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'sage_intacct');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.companyId != null) {
        span.setStringAttribute('sage.company.id', res.companyId!);
      }
      if (res.entityId != null) {
        span.setStringAttribute('sage.entity.id', res.entityId!);
      }
      if (res.moduleName != null) {
        span.setStringAttribute('sage.module', res.moduleName!);
      }
      if (res.recordType != null) {
        span.setStringAttribute('sage.record.type', res.recordType!);
      }
      if (res.recordId != null) {
        span.setStringAttribute('sage.record.id', res.recordId!);
      }
      if (res.amount != null) {
        span.setDoubleAttribute('sage.amount', res.amount!);
      }
      if (res.currency != null) {
        span.setStringAttribute('sage.currency', res.currency!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('sageintacct.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'sageintacct.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
