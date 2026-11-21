import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabkha_app/Features/Recipes/Models/meal.dart';
import 'package:tabkha_app/Features/Recipes/Widgets/meal_card.dart';
import 'package:tabkha_app/Features/Recipes/recipes_providers.dart';
import 'package:tabkha_app/Localization/app_localization_context.dart';
import 'package:tabkha_app/Services/preferences_service.dart';
import 'package:tabkha_app/commonModels/user_preferences.dart';
import 'package:tabkha_app/constants/app_colors.dart';

/// Recipes tab: search, categories and a grid of meals from TheMealDB.
class RecipesView extends ConsumerStatefulWidget {
  const RecipesView({super.key});

  @override
  ConsumerState<RecipesView> createState() => _RecipesViewState();
}

class _RecipesViewState extends ConsumerState<RecipesView> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(searchQueryProvider.notifier).set(value);
    });
  }

  void _toggleLanguage() {
    final current = ref.read(preferencesStateProvider).language;
    ref.read(preferencesStateProvider.notifier).updatePreferences(
          languageCodeEnum: current == LanguageCodeEnum.ar ? LanguageCodeEnum.en : LanguageCodeEnum.ar,
        );
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final category = ref.watch(selectedCategoryProvider);
    final meals = ref.watch(mealsProvider);
    final width = MediaQuery.sizeOf(context).width;
    final columns = (width / 200).floor().clamp(2, 6);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.greenBackground,
          onRefresh: () async {
            ref.invalidate(categoriesProvider);
            ref.invalidate(mealsProvider);
            await ref.read(mealsProvider.future).catchError((_) => <MealSummary>[]);
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Tabkha',
                            style: TextStyle(
                              fontFamily: 'Lobster',
                              fontSize: 28,
                              color: AppColors.greenBackground,
                            ),
                          ),
                          const Spacer(),
                          _FavoritesBadge(count: ref.watch(favoritesProvider).length),
                          const SizedBox(width: 4),
                          IconButton(
                            tooltip: context.loc.changeLanguage,
                            onPressed: _toggleLanguage,
                            icon: const Icon(Icons.translate_rounded, color: AppColors.greenBackground),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.loc.whatToCook,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _search,
                        onChanged: _onSearch,
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(fontFamily: 'Montserrat'),
                        decoration: InputDecoration(
                          hintText: context.loc.searchRecipes,
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: query.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () {
                                    _search.clear();
                                    _debounce?.cancel();
                                    ref.read(searchQueryProvider.notifier).set('');
                                  },
                                ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        context.loc.categories,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: _CategoryStrip()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    layoutBuilder: (current, previous) => Stack(
                      alignment: AlignmentDirectional.centerStart,
                      children: [...previous, if (current != null) current],
                    ),
                    child: Text(
                      query.isEmpty ? context.loc.popularIn(category) : context.loc.resultsFor(query),
                      key: ValueKey('$query|$category'),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              meals.when(
                data: (list) => list.isEmpty
                    ? SliverToBoxAdapter(child: _Message(text: context.loc.noRecipesFound))
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                        sliver: SliverGrid.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.82,
                          ),
                          itemCount: list.length,
                          itemBuilder: (_, i) => MealCard(meal: list[i]),
                        ),
                      ),
                loading: () => _LoadingGrid(columns: columns),
                error: (_, __) => SliverToBoxAdapter(
                  child: _Message(
                    text: context.loc.couldNotLoadRecipes,
                    onRetry: () => ref.invalidate(mealsProvider),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryStrip extends ConsumerWidget {
  const _CategoryStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final selected = ref.watch(selectedCategoryProvider);
    final searching = ref.watch(searchQueryProvider).isNotEmpty;

    return SizedBox(
      height: 104,
      child: categories.when(
        data: (list) => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final category = list[i];
            final active = !searching && category.name == selected;
            return GestureDetector(
              onTap: () => ref.read(selectedCategoryProvider.notifier).select(category.name),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: 84,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? AppColors.greenBackground : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Expanded(child: Image.network(category.thumbnail, fit: BoxFit.contain)),
                    const SizedBox(height: 6),
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : AppColors.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.greenBackground)),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

class _FavoritesBadge extends StatelessWidget {
  const _FavoritesBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,
      label: Text('$count'),
      backgroundColor: const Color(0xFFE2574C),
      child: const Icon(Icons.favorite_rounded, color: Color(0xFFE2574C)),
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid({required this.columns});

  final int columns;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      sliver: SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.82,
        ),
        itemCount: columns * 2,
        itemBuilder: (_, __) => const _Pulse(),
      ),
    );
  }
}

/// A placeholder tile that gently pulses while recipes load.
class _Pulse extends StatefulWidget {
  const _Pulse();

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.45, end: 1.0).animate(_controller),
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      ),
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
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
      child: Column(
        children: [
          const Icon(Icons.ramen_dining_rounded, size: 48, color: AppColors.inkLight),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Montserrat')),
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
