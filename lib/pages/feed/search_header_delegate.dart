import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/models/lieu.dart';
import 'place_filter_chip.dart';
import 'search_field.dart';

/// Sticky search and filter header.
class SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  static const double _height = 108;
  final List<LieuCategorie> filters;
  final LieuCategorie selectedFilter;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<LieuCategorie> onFilterSelected;

  /// Creates a sticky search and filter header.
  const SearchHeaderDelegate({
    required this.filters,
    required this.selectedFilter,
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterSelected,
  });

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: const Border(bottom: BorderSide(color: AppColors.borderSubtle)),
        boxShadow: overlapsContent
            ? const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Column(
          children: [
            SearchField(
              controller: searchController,
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  return PlaceFilterChip(
                    label: filters[index].label,
                    isSelected: filters[index] == selectedFilter,
                    onSelected: () => onFilterSelected(filters[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SearchHeaderDelegate oldDelegate) {
    return oldDelegate.filters != filters ||
        oldDelegate.selectedFilter != selectedFilter ||
        oldDelegate.searchController != searchController ||
        oldDelegate.onSearchChanged != onSearchChanged ||
        oldDelegate.onFilterSelected != onFilterSelected;
  }
}
