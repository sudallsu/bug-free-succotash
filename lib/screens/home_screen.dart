import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';
import '../widgets/video_card.dart';
import 'letters_screen.dart';
import 'notices_screen.dart';
import 'post_detail_screen.dart';
import 'video_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return RefreshIndicator(
      color: AppColors.coral,
      onRefresh: state.load,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(state: state)),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          // 라이브 배너
          if (state.activeLive != null)
            SliverToBoxAdapter(
              child: _LiveBanner(
                live: state.activeLive!,
                onTap: () => onNavigate(3),
              ),
            ),
          if (state.activeLive != null)
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          // 추천 영상
          if (state.featuredVideo != null)
            SliverToBoxAdapter(
              child: FeaturedVideoCard(
                video: state.featuredVideo!,
                onTap: () => _openVideo(context, state.featuredVideo!),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 26)),
          // 퀵 메뉴
          const SliverToBoxAdapter(
            child: SectionHeader(title: '바로가기', emoji: '⚡'),
          ),
          SliverToBoxAdapter(child: _QuickMenu(onNavigate: onNavigate)),
          const SliverToBoxAdapter(child: SizedBox(height: 26)),
          // 공지
          if (state.notices.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: SectionHeader(
                title: '공지사항',
                emoji: '📢',
                actionLabel: '전체보기',
                onAction: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NoticesScreen()),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _NoticePreview(
                notice: state.notices.first,
                unread: !state.readNoticeIds.contains(state.notices.first.id),
                onTap: () {
                  state.markNoticeRead(state.notices.first.id);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NoticesScreen()),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 26)),
          ],
          // 최신 영상
          SliverToBoxAdapter(
            child: SectionHeader(
              title: '최신 영상',
              emoji: '🎬',
              actionLabel: '아카이브 전체',
              onAction: () => onNavigate(1),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.separated(
              itemCount: state.videos.take(3).length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final v = state.videos[i];
                return VideoListTile(
                  video: v,
                  onTap: () => _openVideo(context, v),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 26)),
          // 팬 하이라이트
          SliverToBoxAdapter(
            child: SectionHeader(
              title: '팬 라운지',
              emoji: '💬',
              subtitle: '팬들의 최신 이야기',
              actionLabel: '커뮤니티',
              onAction: () => onNavigate(2),
            ),
          ),
          SliverToBoxAdapter(child: _PostPreviewList(state: state)),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  void _openVideo(BuildContext context, VideoItem v) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => VideoDetailScreen(video: v)));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final ch = state.channel;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.yellow, AppColors.coral],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.tinted(AppColors.coral),
                ),
                child: Text(ch.emoji, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ch.name,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${ch.handle} · 구독자 ${Fmt.count(ch.subscribers)}명',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _HeaderIcon(
                icon: Icons.favorite_rounded,
                badge: state.unreadLetterCount,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LettersScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '안녕하세요,\n${ch.tagline}',
            style: const TextStyle(
              fontSize: 23,
              height: 1.35,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
              letterSpacing: -0.9,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, this.badge = 0, this.onTap});
  final IconData icon;
  final int badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: AppShadows.soft,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 22, color: AppColors.coral),
            if (badge > 0)
              Positioned(
                top: 9,
                right: 9,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.coralDeep,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge > 9 ? '9+' : '$badge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LiveBanner extends StatelessWidget {
  const _LiveBanner({required this.live, required this.onTap});
  final LiveSession live;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const _PulsingDot(),
            const SizedBox(width: 9),
            const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                live.title.replaceFirst('🔴 ', ''),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                const Icon(
                  Icons.remove_red_eye_rounded,
                  size: 13,
                  color: Colors.white70,
                ),
                const SizedBox(width: 3),
                Text(
                  Fmt.count(live.viewers),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.coral,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.coral.withValues(alpha: 0.3 + _c.value * 0.5),
              blurRadius: 4 + _c.value * 6,
              spreadRadius: _c.value * 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickMenu extends StatelessWidget {
  const _QuickMenu({required this.onNavigate});
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('🎬', '영상\n아카이브', AppColors.skySoft, AppColors.sky, 1),
      ('💬', '팬\n라운지', AppColors.mintSoft, AppColors.mint, 2),
      ('🎥', '라이브\n일정', AppColors.lilacSoft, AppColors.lilac, 3),
      ('💌', '팬\n레터', AppColors.yellowSoft, const Color(0xFFD99A00), 4),
    ];
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 11),
        itemBuilder: (context, i) {
          final (emoji, label, soft, color, index) = items[i];
          return GestureDetector(
            onTap: () => onNavigate(index),
            child: Container(
              width: 86,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: soft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 7),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NoticePreview extends StatelessWidget {
  const _NoticePreview({
    required this.notice,
    required this.onTap,
    this.unread = false,
  });
  final Notice notice;
  final VoidCallback onTap;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.line, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.yellowSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.campaign_rounded,
                size: 20,
                color: Color(0xFFD99A00),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (unread)
                        Container(
                          margin: const EdgeInsets.only(right: 5),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.coral,
                            shape: BoxShape.circle,
                          ),
                        ),
                      Flexible(
                        child: Text(
                          notice.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notice.body.replaceAll('\n', ' '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              Fmt.date(notice.createdAt),
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostPreviewList extends StatelessWidget {
  const _PostPreviewList({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final posts = state.posts.take(2).toList();
    if (posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: EmptyState(
          emoji: '💬',
          title: '아직 팬 글이 없어요',
          message: '첫 번째 글을 남겨보세요!',
        ),
      );
    }
    return Column(children: posts.map((p) => _PostPreview(post: p)).toList());
  }
}

class _PostPreview extends StatelessWidget {
  const _PostPreview({required this.post});
  final CommunityPost post;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => PostDetailScreen(post: post))),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EmojiAvatar(emoji: post.emoji, size: 38),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        post.author,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(width: 6),
                      LevelBadge(level: post.level),
                      const Spacer(),
                      Text(
                        Fmt.date(post.createdAt),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    post.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: AppColors.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite_rounded,
                        size: 13,
                        color: AppColors.coral,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${post.likeCount}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.coral,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.mode_comment_rounded,
                        size: 12,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${post.comments.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
