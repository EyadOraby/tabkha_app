import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabkha_app/Features/Recipes/Models/meal.dart';
import 'package:tabkha_app/Features/Recipes/Widgets/meal_card.dart';
import 'package:tabkha_app/Features/Recipes/recipes_providers.dart';
import 'package:tabkha_app/Localization/app_localization_context.dart';
import 'package:tabkha_app/constants/app_colors.dart';

/// A recipe: photo, ingredients with measures and numbered steps.
class MealDetailsView extends ConsumerWidget {
  const MealDetailsView({super.key, required this.summary});

  final MealSummary summary;

  static Route<void> route(MealSummary summary) => MaterialPageRoute(
        builder: (_) => MealDetailsView(summary: summary),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meal = ref.watch(mealProvider(summary.id));
    final isFavorite = ref.watch(favoritesProvider.select((ids) => ids.contains(summary.id)));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.greenBackground,
            foregroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Material(
                color: Colors.white.withValues(alpha: 0.92),
                shape: const CircleBorder(),
                child: const BackButton(color: AppColors.textColor),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: FavoriteButton(mealId: summary.id, isFavorite: isFavorite),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Hero(
                tag: 'meal-${summary.id}',
                child: Image.network(
                  summary.thumbnail.isNotEmpty ? summary.thumbnail : meal.value?.thumbnail ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const ColoredBox(color: AppColors.skyLighter),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              transform: Matrix4.translationValues(0, -24, 0),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: meal.when(
                data: (meal) => meal == null
                    ? _Message(text: context.loc.recipeNotFound)
                    : _MealBody(meal: meal),
                loading: () => _Header(name: summary.name, loading: true),
                error: (_, __) => _Message(
                  text: context.loc.couldNotLoadRecipes,
                  onRetry: () => ref.invalidate(mealProvider(summary.id)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, this.tags = const [], this.loading = false});

  final String name;
  final List<String> tags;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textColor,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(color: AppColors.greenBackground)),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in tags.where((t) => t.isNotEmpty))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.greenBackground.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.greenBackground,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _MealBody extends StatelessWidget {
  const _MealBody({required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(name: meal.name, tags: [meal.category, meal.area]),
        const SizedBox(height: 28),
        _SectionTitle(title: context.loc.ingredients, count: meal.ingredients.length),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              for (final (i, ingredient) in meal.ingredients.indexed) ...[
                if (i > 0) const Divider(height: 1, color: AppColors.skyLighter),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.greenBackground,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ingredient.name,
                          style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
                        ),
                      ),
                      Text(
                        ingredient.measure,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          color: AppColors.inkLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 28),
        _SectionTitle(title: context.loc.steps, count: meal.steps.length),
        const SizedBox(height: 12),
        for (final (i, step) in meal.steps.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.greenBackground,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step,
                    style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, height: 1.55),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 8),
        Text('$count', style: const TextStyle(fontFamily: 'Nunito', color: AppColors.inkLight)),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.ramen_dining_rounded, size: 48, color: AppColors.inkLight),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Nunito')),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.greenBackground),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.loc.tryAgain),
            ),
          ],
        ],
      ),
    );
  }
}
