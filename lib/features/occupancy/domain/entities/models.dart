import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Models { both, knn, lstm }

final modelsProvider = StateProvider<Models>((ref) => Models.both);
