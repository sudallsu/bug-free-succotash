import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/video_card.dart';
import 'video_detail_screen.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  String _category = '전체';
  String _query = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final filtered = state.videos.where((v) {
      final catOk = _category == '전체' || v.category == _category;
      final q = _query.trim().toLowerCase();
      final queryOk =
          q.isEmpty ||
          v.title.toLowerCase().contains(q) ||
          v.description.toLowerCase().contains(q) ||
          v.category.toLowerCase().contains(q) ||
          v.tags.any((t) => t.toLowerCase().contains(q));
      return catOk && queryOk;
    }).toList();

    return RefreshIndicator(
      color: AppColors.coral,
      onRefresh: state.load,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(state.videos.length)),
          SliverToBoxAdapter(child: _buildSearch()),
          SliverToBoxAdapter(child: _buildCategories(state)),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          if (filtered.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                emoji: '🔍',
                title: '검색 결과가 없어요',
                message: '다른 키워드나 카테고리로 찾아보세요.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 13,
                  childAspectRatio: 0.88,
                ),
                delegate: SliverChildBuilderDelegate(
                  childCount: filtered.length,
                  (context, i) {
                    final v = filtered[i];
                    return VideoCard(
                      video: v,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => VideoDetailScreen(video: v),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }

  Widget _buildHeader(int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '영상 아카이브',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 25),
              ),
              const SizedBox(width: 7),
              const Text('🎬', style: TextStyle(fontSize: 21)),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '지금까지 함께한 $total개의 순간들',
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _query = v),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: '영상 제목, 태그로 검색',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.muted,
            size: 21,
          ),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 19,
                    color: AppColors.muted,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildCategories(AppState state) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: state.categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = state.categories[i];
          return CategoryChip(
            label: cat == '전체' ? '전체' : cat,
            selected: _category == cat,
            color: cat == '전체' ? AppColors.coral : AppColors.categoryColor(cat),
            onTap: () => setState(() => _category = cat),
          );
        },
      ),
    );
  }
}
