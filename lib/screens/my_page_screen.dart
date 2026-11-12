import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';
import 'events_screen.dart';
import 'letters_screen.dart';
import 'notices_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.profile;
    final myPosts = state.posts.where((p) => p.isMine).length;
    final myLetters = state.letters.where((l) => l.isMine).length;

    return RefreshIndicator(
      color: AppColors.coral,
      onRefresh: state.load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 34),
        children: [
          // 프로필 카드
          Container(
            margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFE3D3), Color(0xFFFFF0C9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _editEmoji(context, state),
                      child: Container(
                        width: 66,
                        height: 66,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.soft,
                        ),
                        child: Text(
                          profile.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  profile.nickname,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.ink,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => _editNickname(context, state),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  size: 15,
                                  color: AppColors.inkSoft,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              LevelBadge(
                                level: profile.level,
                                color: AppColors.white,
                                textColor: const Color(0xFF9A6B00),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${Fmt.won(profile.points)}P',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF8A6200),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.66),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      _stat('내 글', '$myPosts'),
                      _divider(),
                      _stat('보낸 편지', '$myLetters'),
                      _divider(),
                      _stat('활동', '${_daysSince(profile.joinedAt)}일'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: '내 활동', emoji: '📚'),
          _menu(
            icon: Icons.favorite_rounded,
            iconColor: AppColors.coral,
            title: '받은 팬 레터',
            subtitle: '읽지 않은 편지 ${state.unreadLetterCount}통',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const LettersScreen())),
          ),
          _menu(
            icon: Icons.campaign_rounded,
            iconColor: const Color(0xFFD99A00),
            title: '공지사항',
            subtitle: '새 소식 ${state.notices.length}건',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const NoticesScreen())),
          ),
          _menu(
            icon: Icons.card_giftcard_rounded,
            iconColor: AppColors.lilac,
            title: '이벤트 & 굿즈',
            subtitle: '진행 중 ${state.events.where((e) => e.isOngoing).length}건',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const EventsScreen())),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: '앱 정보', emoji: '⚙️'),
          _menu(
            icon: Icons.cloud_done_rounded,
            iconColor: AppColors.mint,
            title: '데이터 연결 상태',
            subtitle: state.isCloud
                ? 'Firebase Firestore 연결됨'
                : '로컬 데모 모드 (오프라인)',
            onTap: () => _showCloudInfo(context, state),
          ),
          _menu(
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.sky,
            title: '앱 버전',
            subtitle: 'FanHub Archive v1.0.0',
            onTap: null,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.creamDeep,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Text('🌷', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '이 공간은 팬과 크리에이터가 함께 만드는 아카이브입니다.\n언제나 응원해주셔서 감사해요!',
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.6,
                        color: AppColors.inkSoft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _daysSince(DateTime d) => DateTime.now().difference(d).inDays + 1;

  Widget _stat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.inkSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 26,
    color: AppColors.ink.withValues(alpha: 0.08),
  );

  Widget _menu({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 9),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, size: 19, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.muted,
              ),
          ],
        ),
      ),
    );
  }

  void _editNickname(BuildContext context, AppState state) {
    final controller = TextEditingController(text: state.profile.nickname);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          '닉네임 변경',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 12,
          decoration: const InputDecoration(hintText: '새 닉네임을 입력하세요'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소', style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () {
              final v = controller.text.trim();
              if (v.isNotEmpty) state.updateProfile(nickname: v);
              Navigator.of(context).pop();
            },
            child: const Text(
              '저장',
              style: TextStyle(
                color: AppColors.coral,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editEmoji(BuildContext context, AppState state) {
    const emojis = [
      '🌷',
      '🍑',
      '☁️',
      '⭐',
      '🌙',
      '🌻',
      '🍃',
      '🐰',
      '🐣',
      '🌈',
      '🍓',
      '🌸',
      '💫',
      '🐻',
      '🍋',
      '🫧',
    ];
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              '프로필 이모지 선택',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: emojis
                  .map(
                    (e) => GestureDetector(
                      onTap: () {
                        state.updateProfile(emoji: e);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: e == state.profile.emoji
                              ? AppColors.yellowSoft
                              : AppColors.creamDeep,
                          shape: BoxShape.circle,
                          border: e == state.profile.emoji
                              ? Border.all(color: AppColors.yellow, width: 2)
                              : null,
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showCloudInfo(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(
              state.isCloud
                  ? Icons.cloud_done_rounded
                  : Icons.cloud_off_rounded,
              color: state.isCloud ? AppColors.mint : AppColors.muted,
            ),
            const SizedBox(width: 8),
            const Text(
              '데이터 연결',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          state.isCloud
              ? 'Firebase Firestore에 연결되어 있어요.\n'
                    '작성한 글과 편지가 모든 팬들과 실시간으로 공유됩니다.'
              : '현재 로컬 데모 모드로 동작 중이에요.\n\n'
                    'Firebase 프로젝트를 연결하면 작성한 글이 클라우드에 저장되고 '
                    '모든 팬들과 실시간으로 공유됩니다.\n\n'
                    '· Android: google-services.json 추가\n'
                    '· Web: firebase_options.dart 추가',
          style: const TextStyle(fontSize: 12.5, height: 1.65),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '확인',
              style: TextStyle(
                color: AppColors.coral,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
