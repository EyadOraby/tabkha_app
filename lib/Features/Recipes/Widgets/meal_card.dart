import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabkha_app/Features/Recipes/Models/meal.dart';
import 'package:tabkha_app/Features/Recipes/Views/meal_details_view.dart';
import 'package:tabkha_app/Features/Recipes/recipes_providers.dart';
import 'package:tabkha_app/Localization/app_localization_context.dart';
import 'package:tabkha_app/constants/app_colors.dart';

/// A recipe tile: photo, name and a favourite toggle. Opens the details.
class MealCard extends ConsumerWidget {
  const MealCard({super.key, required this.meal});

  final MealSummary meal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider.select((ids) => ids.contains(meal.id)));
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MealDetailsView.route(meal)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'meal-${meal.id}',
              child: Image.network(
                meal.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(color: AppColors.skyLighter),
                frameBuilder: (context, child, frame, sync) => AnimatedOpacity(
                  opacity: frame == null && !sync ? 0 : 1,
                  duration: const Duration(milliseconds: 300),
                  child: child,
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.45, 1],
                  colors: [Colors.transparent, Color(0xCC0B2A1C)],
                ),
              ),
            ),
            PositionedDirectional(
              start: 14,
              end: 14,
              bottom: 12,
              child: Text(
                meal.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.25,
                ),
              ),
            ),
            PositionedDirectional(
              top: 8,
              end: 8,
              child: FavoriteButton(mealId: meal.id, isFavorite: isFavorite, compact: true),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.mealId, required this.isFavorite, this.compact = false});

  final String mealId;
  final bool isFavorite;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: IconButton(
        visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
        tooltip: isFavorite ? context.loc.removeFromFavorites : context.loc.addToFavorites,
        onPressed: () => ref.read(favoritesProvider.notifier).toggle(mealId),
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey(isFavorite),
            color: isFavorite ? const Color(0xFFE2574C) : AppColors.inkLight,
            size: compact ? 20 : 24,
          ),
        ),
      ),
    );
  }
}
