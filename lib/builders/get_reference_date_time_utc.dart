import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/reference_datetime.dart';

/// Builder callback signature for GetReferenceDateTimeUtc.
typedef ReferenceDateTimeUtcBuilder =
    Widget Function(DateTime referenceDateTimeUtcProvider);

/// Builder widget that provides the reference date time.
/// Use this when you need access to the reference time.
class GetReferenceDateTimeUtc extends ConsumerWidget {
  const GetReferenceDateTimeUtc({super.key, required this.builder});

  final ReferenceDateTimeUtcBuilder builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referenceDate =
        ref.watch(referenceDateTimeUtcProvider) ?? DateTime.now().toUtc();

    return builder(referenceDate);
  }
}
