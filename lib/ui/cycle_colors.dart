import 'package:flutter/material.dart';

import '../domain/cycle_predictor.dart';

/// Colours with a fixed meaning across the app, tuned for light and dark.
class CycleColors {
  const CycleColors._(this._dark);

  factory CycleColors.of(BuildContext context) =>
      CycleColors._(Theme.of(context).brightness == Brightness.dark);

  final bool _dark;

  Color get period => _dark ? const Color(0xFFFF6F91) : const Color(0xFFD6336C);
  Color get fertile =>
      _dark ? const Color(0xFF4FD1C5) : const Color(0xFF0E9384);
  Color get follicular =>
      _dark ? const Color(0xFFB197FC) : const Color(0xFF7048E8);
  Color get luteal => _dark ? const Color(0xFFFFC078) : const Color(0xFFE8590C);

  Color phase(CyclePhase p) => switch (p) {
    CyclePhase.menstrual => period,
    CyclePhase.follicular => follicular,
    CyclePhase.ovulation => fertile,
    CyclePhase.luteal => luteal,
  };
}
