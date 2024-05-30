
import 'package:flutter/material.dart';

@immutable
class Timing {
  final int? opening;
  final int? closing;
  final bool isOpen;

  const Timing({
    this.opening,
    this.closing,
    required this.isOpen,
  });

  static Timing fromJson(Map<String, dynamic> json) {
    return Timing(
      opening: json['opening'] != null ? json['opening'] as int : null,
      closing: json['closing'] != null ? json['closing'] as int : null,
      isOpen: json['open'] as bool,
    );
  }
}
