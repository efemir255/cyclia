import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../domain/cycle_predictor.dart';
import '../cycle_colors.dart';

/// A ring showing the cycle's phases, with a marker on today.
class CycleRing extends StatelessWidget {
  const CycleRing({super.key, required this.forecast, required this.child});

  final CycleForecast forecast;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = CycleColors.of(context);
    final f = forecast;
    final length = math.max(f.averageCycleLength, f.cycleDay);
    // Day of the cycle on which ovulation is estimated.
    final ovulationDay =
        f.averageCycleLength - CyclePredictor.lutealPhaseLength;
    final fertile = CyclePredictor.fertileWindowFor(
      addDays(f.lastPeriodStart, ovulationDay - 1),
    );
    final fertileFirst = daysBetween(f.lastPeriodStart, fertile.start) + 1;
    final fertileLast = daysBetween(f.lastPeriodStart, fertile.end) + 1;

    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _RingPainter(
          length: length,
          today: f.cycleDay,
          // Later segments are painted over earlier ones, so a short cycle
          // where the fertile window overlaps the period still reads clearly.
          segments: [
            (f.averagePeriodLength + 1, fertileFirst - 1, colors.follicular),
            (fertileLast + 1, f.averageCycleLength, colors.luteal),
            (fertileFirst, fertileLast, colors.fertile),
            (1, f.averagePeriodLength, colors.period),
          ],
          track: Theme.of(context).colorScheme.surfaceContainerHighest,
          marker: Theme.of(context).colorScheme.onSurface,
        ),
        child: Center(
          child: Padding(padding: const EdgeInsets.all(40), child: child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.length,
    required this.today,
    required this.segments,
    required this.track,
    required this.marker,
  });

  final int length;
  final int today;

  /// (first day, last day, colour), 1-based and inclusive.
  final List<(int, int, Color)> segments;
  final Color track;
  final Color marker;

  static const _stroke = 18.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(_stroke);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(arcRect, 0, 2 * math.pi, false, paint..color = track);

    final perDay = 2 * math.pi / length;
    const top = -math.pi / 2;
    for (final (first, last, color) in segments) {
      final from = math.max(first, 1);
      final to = math.min(last, length);
      if (to < from) continue;
      canvas.drawArc(
        arcRect,
        top + (from - 1) * perDay,
        (to - from + 1) * perDay,
        false,
        paint..color = color.withValues(alpha: 0.85),
      );
    }

    // Marker in the middle of today's slot.
    final angle = top + (today - 0.5) * perDay;
    final radius = arcRect.width / 2;
    final center = rect.center;
    final pos = center + Offset(math.cos(angle), math.sin(angle)) * radius;
    canvas.drawCircle(pos, _stroke * 0.75, Paint()..color = marker);
    canvas.drawCircle(pos, _stroke * 0.45, Paint()..color = track);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.length != length ||
      old.today != today ||
      old.segments != segments ||
      old.track != track;
}
