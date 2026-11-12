import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';
import '../widgets/video_card.dart';
import 'post_detail_screen.dart';

class VideoDetailScreen extends StatelessWidget {
  const VideoDetailScreen({super.key, required this.video});
  final VideoItem video;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final catColor = AppColors.categoryColor(video.category);
    final catSoft = AppColors.categorySoft(video.category);
    final liked = state.isVideoLiked(video.id);

    // 현재 상태 기준 최신 데이터 사용
    final current = state.videos.firstWhere(
      (v) => v.id == video.id,
      orElse: () => video,
    );

    final related = state.videos
        .where((v) => v.id != current.id && v.category == current.category)
        .take(3)
        .toList();

    final relatedPosts = state.posts
        .where((p) => p.videoId == current.id)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 250,
            backgroundColor: catSoft,
            surfaceTintColor: Colors.transparent,
            leading: _CircleBack(),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(color: catSoft),
                child: Stack(
                  children: [
                    Positioned(
                      right: -40,
                      top: 30,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Text(
                            current.emoji,
                            style: const TextStyle(fontSize: 68),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${current.category} · ${current.durationLabel}',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: catColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _CircleBack(
                  icon: Icons.ios_share_rounded,
                  onTap: () => _share(context, current),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    current.title,
                    style: const TextStyle(
                      fontSize: 21,
                      height: 1.3,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        Fmt.dateFull(current.publishedAt),
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 통계
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppShadows.soft,
                    ),
                    child: Row(
                      children: [
                        _stat(
                          Icons.play_circle_fill_rounded,
                          Fmt.count(current.views),
                          '조회수',
                          AppColors.sky,
                        ),
                        _divider(),
                        _stat(
                          Icons.favorite_rounded,
                          Fmt.count(current.likes),
                          '좋아요',
                          AppColors.coral,
                        ),
                        _divider(),
                        _stat(
                          Icons.mode_comment_rounded,
                          Fmt.count(current.comments),
                          '댓글',
                          AppColors.mint,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 설명
                  if (current.description.isNotEmpty) ...[
                    Text(
                      current.description,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.65,
                        color: AppColors.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (current.tags.isNotEmpty)
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: current.tags
                          .map(
                            (t) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.creamDeep,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '#$t',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.inkSoft,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 22),
                  // 액션 버튼
                  Row(
                    children: [
                      Expanded(
                        child: PillButton(
                          label: liked
                              ? '좋아요 ${Fmt.count(current.likes)}'
                              : '좋아요',
                          icon: liked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          expanded: true,
                          color: liked ? AppColors.coral : AppColors.white,
                          textColor: liked ? Colors.white : AppColors.inkSoft,
                          onPressed: () => state.likeVideo(current.id),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: PillButton(
                          label: '팬 라운지에 글쓰기',
                          icon: Icons.edit_rounded,
                          expanded: true,
                          color: AppColors.ink,
                          onPressed: () => _writePost(context, current),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                ],
              ),
            ),
          ),
          if (relatedPosts.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: const SectionHeader(title: '이 영상에 대한 팬 이야기', emoji: '💬'),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: relatedPosts.length,
                separatorBuilder: (_, _) => const SizedBox(height: 9),
                itemBuilder: (context, i) {
                  final p = relatedPosts[i];
                  return _RelatedPost(post: p);
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
          if (related.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: SectionHeader(title: '같은 카테고리 영상', emoji: '✨'),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: related.length,
                separatorBuilder: (_, _) => const SizedBox(height: 9),
                itemBuilder: (context, i) => VideoListTile(
                  video: related[i],
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => VideoDetailScreen(video: related[i]),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 30, color: AppColors.line);

  void _share(BuildContext context, VideoItem v) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('"${v.title}" 링크를 공유할 준비가 됐어요 🔗')));
  }

  void _writePost(BuildContext context, VideoItem v) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(
          post: CommunityPost(
            id: 'new',
            author: '',
            emoji: '',
            level: '',
            body: '',
            createdAt: DateTime.now(),
            tag: '감상',
            videoId: v.id,
          ),
          composeMode: true,
          composeVideoTitle: v.title,
        ),
      ),
    );
  }
}

class _CircleBack extends StatelessWidget {
  const _CircleBack({this.icon = Icons.arrow_back_ios_new_rounded, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
        child: Container(
          width: 38,
          height: 38,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: AppShadows.soft,
          ),
          child: Icon(icon, size: 17, color: AppColors.ink),
        ),
      ),
    );
  }
}

class _RelatedPost extends StatelessWidget {
  const _RelatedPost({required this.post});
  final CommunityPost post;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmojiAvatar(emoji: post.emoji, size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.author,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  post.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
