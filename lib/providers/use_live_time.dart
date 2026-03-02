import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether to use live DateTime.now().toUtc() as the reference time.
/// When true, referenceDateTimeUtcProvider returns current time.
/// When false, uses the custom time set by the user.
final useLiveTimeProvider = StateProvider<bool>((ref) => true);
