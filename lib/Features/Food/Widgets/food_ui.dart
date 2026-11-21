import 'package:flutter/material.dart';
import 'package:tabkha_app/Features/Food/Models/food_models.dart';
import 'package:tabkha_app/constants/app_colors.dart';

const ink = Color(0xFF1B2A24);
const inkMuted = Color(0xFF66756F);
const cream = Color(0xFFF7F4EE);
const saffron = Color(0xFFE8A33D);
const tomato = Color(0xFFE2574C);

String egp(double v) => 'EGP ${v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2)}';

const titleStyle = TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w800, color: ink);
const bodyStyle = TextStyle(fontFamily: 'Montserrat', color: inkMuted, height: 1.4);

class NetImage extends StatelessWidget {
  const NetImage(this.url, {super.key, this.radius = 18, this.fit = BoxFit.cover});

  final String url;
  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url.isEmpty
          ? const ColoredBox(color: Color(0xFFE9E4DA), child: Center(child: Icon(Icons.restaurant, color: inkMuted)))
          : Image.network(
              url,
              fit: fit,
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: Color(0xFFE9E4DA), child: Center(child: Icon(Icons.restaurant, color: inkMuted))),
              frameBuilder: (context, child, frame, sync) => AnimatedOpacity(
                opacity: frame == null && !sync ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: child,
              ),
            ),
    );
  }
}

class RatingPill extends StatelessWidget {
  const RatingPill({super.key, required this.rating, this.count, this.light = false});

  final double rating;
  final int? count;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: light ? Colors.white : saffron.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 15, color: saffron),
          const SizedBox(width: 3),
          Text(
            rating == 0 ? 'New' : rating.toStringAsFixed(1) + (count == null ? '' : ' ($count)'),
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.w700, color: ink),
          ),
        ],
      ),
    );
  }
}

Color statusColor(OrderStatus s) => switch (s) {
      OrderStatus.placed => saffron,
      OrderStatus.accepted => const Color(0xFF5B8DEF),
      OrderStatus.preparing => const Color(0xFF9B7CF0),
      OrderStatus.onTheWay => const Color(0xFF14A3B8),
      OrderStatus.delivered => AppColors.greenBackground,
      OrderStatus.cancelled => tomato,
    };

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final c = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20)),
      child: Text(status.label,
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.w700, color: c)),
    );
  }
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.icon, required this.label, required this.value, this.color});

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.greenBackground;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: c, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: titleStyle.copyWith(fontSize: 24)),
          const SizedBox(height: 2),
          Text(label, style: bodyStyle.copyWith(fontSize: 12.5)),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 22, 0, 12),
      child: Row(
        children: [
          Expanded(child: Text(text, style: titleStyle.copyWith(fontSize: 18))),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// A five-step progress line for an order.
class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    const steps = [OrderStatus.placed, OrderStatus.accepted, OrderStatus.preparing, OrderStatus.onTheWay, OrderStatus.delivered];
    final reached = steps.indexOf(status);
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Tooltip(
            message: steps[i].label,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i <= reached ? AppColors.greenBackground : const Color(0xFFE4E0D6),
              ),
              child: i <= reached ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
            ),
          ),
          if (i < steps.length - 1)
            Expanded(
              child: Container(
                height: 3,
                color: i < reached ? AppColors.greenBackground : const Color(0xFFE4E0D6),
              ),
            ),
        ],
      ],
    );
  }
}
