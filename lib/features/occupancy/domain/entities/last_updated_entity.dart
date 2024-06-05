import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final lastUpdatedProvider = Provider<HashMap<String, DateTime>>((ref) => HashMap());
