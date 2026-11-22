import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Tabkha's illustration style: hand-drawn ingredient doodles with a flat
/// colour shape printed slightly off the ink outline, like a two-colour
/// risograph print on a kitchen notebook.
enum Ingredient { tomato, garlic, chili, basil, lemon, onion, spoon, pot, bread }

class KitchenDoodle extends StatelessWidget {
  const KitchenDoodle(this.ingredient, {super.key, this.size = 48});

  final Ingredient ingredient;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _DoodlePainter(ingredient)),
      );
}

/// A loose scatter of doodles, for headers and empty states.
class IngredientScatter extends StatelessWidget {
  const IngredientScatter({super.key, this.items = Ingredient.values, this.size = 44, this.seed = 3});

  final List<Ingredient> items;
  final double size;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final rnd = math.Random(seed);
    return Wrap(
      spacing: size * .15,
      runSpacing: size * .1,
      alignment: WrapAlignment.center,
      children: [
        for (final i in items)
          Transform.rotate(angle: (rnd.nextDouble() - .5) * .6, child: KitchenDoodle(i, size: size * (.85 + rnd.nextDouble() * .3))),
      ],
    );
  }
}

/// An empty state with a pot and a few ingredients above the message.
class KitchenEmptyState extends StatelessWidget {
  const KitchenEmptyState({super.key, required this.title, this.message, this.action});

  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 180,
              child: IngredientScatter(items: [Ingredient.basil, Ingredient.pot, Ingredient.tomato], size: 56),
            ),
            const SizedBox(height: 18),
            Text(title, textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(message!, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
            if (action != null) ...[const SizedBox(height: 18), action!],
          ],
        ),
      ),
    );
  }
}

const _ink = Color(0xFF2B2118);
const _tomato = Color(0xFFE8705A);
const _herb = Color(0xFF7FA36B);
const _lemon = Color(0xFFF2C94C);
const _garlic = Color(0xFFF3E7D3);
const _onion = Color(0xFFC98BB0);
const _wood = Color(0xFFD7A465);
const _pot = Color(0xFF5E8A84);

class _DoodlePainter extends CustomPainter {
  _DoodlePainter(this.ingredient);

  final Ingredient ingredient;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final fill = Paint();
    final line = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.4, s * .035)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // The colour layer is printed slightly up and to the left of the ink.
    final off = Offset(-s * .05, -s * .04);

    void shape(Path p, Color c) {
      canvas.drawPath(p.shift(off), fill..color = c);
      canvas.drawPath(p, line);
    }

    Path oval(double cx, double cy, double w, double h) =>
        Path()..addOval(Rect.fromCenter(center: Offset(s * cx, s * cy), width: s * w, height: s * h));

    switch (ingredient) {
      case Ingredient.tomato:
        shape(oval(.5, .56, .72, .62), _tomato);
        final leaf = Path()
          ..moveTo(s * .5, s * .26)
          ..lineTo(s * .38, s * .2)
          ..moveTo(s * .5, s * .26)
          ..lineTo(s * .62, s * .19)
          ..moveTo(s * .5, s * .26)
          ..lineTo(s * .5, s * .14);
        canvas.drawPath(leaf, line..color = const Color(0xFF3F6B3A));
        line.color = _ink;
      case Ingredient.garlic:
        final bulb = Path()
          ..moveTo(s * .5, s * .16)
          ..quadraticBezierTo(s * .54, s * .34, s * .74, s * .5)
          ..quadraticBezierTo(s * .86, s * .8, s * .5, s * .84)
          ..quadraticBezierTo(s * .14, s * .8, s * .26, s * .5)
          ..quadraticBezierTo(s * .46, s * .34, s * .5, s * .16);
        shape(bulb, _garlic);
        canvas.drawPath(
            Path()
              ..moveTo(s * .5, s * .36)
              ..quadraticBezierTo(s * .42, s * .6, s * .5, s * .84),
            line);
      case Ingredient.chili:
        final pod = Path()
          ..moveTo(s * .26, s * .3)
          ..quadraticBezierTo(s * .5, s * .36, s * .66, s * .56)
          ..quadraticBezierTo(s * .8, s * .74, s * .86, s * .88)
          ..quadraticBezierTo(s * .6, s * .8, s * .42, s * .6)
          ..quadraticBezierTo(s * .26, s * .46, s * .26, s * .3);
        shape(pod, const Color(0xFFD9583B));
        canvas.drawLine(Offset(s * .26, s * .3), Offset(s * .16, s * .16), line);
      case Ingredient.basil:
        final leaf = Path()
          ..moveTo(s * .2, s * .8)
          ..quadraticBezierTo(s * .18, s * .3, s * .78, s * .18)
          ..quadraticBezierTo(s * .74, s * .72, s * .2, s * .8);
        shape(leaf, _herb);
        canvas.drawPath(
            Path()
              ..moveTo(s * .2, s * .8)
              ..quadraticBezierTo(s * .44, s * .5, s * .7, s * .28),
            line);
      case Ingredient.lemon:
        shape(oval(.5, .5, .74, .74), _lemon);
        for (var k = 0; k < 6; k++) {
          final a = k * math.pi / 3;
          canvas.drawLine(Offset(s * .5, s * .5), Offset(s * .5 + math.cos(a) * s * .28, s * .5 + math.sin(a) * s * .28), line);
        }
      case Ingredient.onion:
        final bulb = Path()
          ..moveTo(s * .5, s * .14)
          ..quadraticBezierTo(s * .58, s * .36, s * .78, s * .5)
          ..quadraticBezierTo(s * .9, s * .82, s * .5, s * .86)
          ..quadraticBezierTo(s * .1, s * .82, s * .22, s * .5)
          ..quadraticBezierTo(s * .42, s * .36, s * .5, s * .14);
        shape(bulb, _onion);
        canvas.drawArc(Rect.fromLTWH(s * .32, s * .4, s * .36, s * .44), math.pi * 1.1, math.pi * .8, false, line);
      case Ingredient.spoon:
        shape(oval(.36, .32, .34, .44), _wood);
        canvas.drawLine(Offset(s * .46, s * .5), Offset(s * .82, s * .88), line..strokeWidth = s * .07);
        line.strokeWidth = math.max(1.4, s * .035);
      case Ingredient.pot:
        final body = Path()
          ..moveTo(s * .16, s * .4)
          ..lineTo(s * .84, s * .4)
          ..lineTo(s * .78, s * .82)
          ..quadraticBezierTo(s * .5, s * .9, s * .22, s * .82)
          ..close();
        shape(body, _pot);
        canvas.drawLine(Offset(s * .08, s * .46), Offset(s * .16, s * .46), line);
        canvas.drawLine(Offset(s * .84, s * .46), Offset(s * .92, s * .46), line);
        // Steam.
        for (final x in [.38, .5, .62]) {
          canvas.drawPath(
              Path()
                ..moveTo(s * x, s * .32)
                ..quadraticBezierTo(s * (x - .05), s * .24, s * x, s * .17)
                ..quadraticBezierTo(s * (x + .05), s * .1, s * x, s * .04),
              line);
        }
      case Ingredient.bread:
        final loaf = Path()
          ..moveTo(s * .14, s * .7)
          ..quadraticBezierTo(s * .14, s * .3, s * .5, s * .3)
          ..quadraticBezierTo(s * .86, s * .3, s * .86, s * .7)
          ..close();
        shape(loaf, _wood);
        for (final x in [.36, .5, .64]) {
          canvas.drawLine(Offset(s * x, s * .42), Offset(s * (x + .06), s * .52), line);
        }
    }
  }

  @override
  bool shouldRepaint(_DoodlePainter old) => old.ingredient != ingredient;
}
