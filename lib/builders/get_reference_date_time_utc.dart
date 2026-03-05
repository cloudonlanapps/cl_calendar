import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/reference_datetime.dart';

/// Builder callback signature for GetReferenceDateTimeUtc.
/// The DateTime? is null when using live time (SDK handles current time internally).
typedef ReferenceDateTimeUtcBuilder = Widget Function(DateTime? referenceDate);

/// Builder widget that provides the reference date time.
/// Use this when you need access to the reference time.
///
/// When using live time, the referenceDate will be null.
/// Pass null to the SDK - it handles current time internally.
class GetReferenceDateTimeUtc extends ConsumerWidget {
  const GetReferenceDateTimeUtc({required this.builder, super.key});

  final ReferenceDateTimeUtcBuilder builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referenceDate = ref.watch(referenceDateTimeUtcProvider);
    return builder(referenceDate);
  }
}
