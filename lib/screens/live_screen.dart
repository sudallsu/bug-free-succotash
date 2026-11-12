import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';
import 'events_screen.dart';

class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final live = state.activeLive;
    final upcoming = state.upcomingLives;
    final replays = state.replayLives;

    return RefreshIndicator(
      color: AppColors.coral,
      onRefresh: state.load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 30),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '라이브 & 일정',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(fontSize: 25),
                    ),
                    const SizedBox(width: 7),
                    const Text('🎥', style: TextStyle(fontSize: 21)),
                  ],
                ),
                const SizedBox(height: 5),
                const Text(
                  '실시간으로 만나고, 놓친 방송은 다시 봐요',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (live != null) _LiveNowCard(live: live),
          if (live != null) const SizedBox(height: 26),
          if (upcoming.isNotEmpty) ...[
            const SectionHeader(title: '다가오는 라이브', emoji: '📅'),
            ...upcoming.map((l) => _UpcomingCard(live: l)),
            const SizedBox(height: 26),
          ],
          // 이벤트/굿즈 배너
          _EventShortcut(
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const EventsScreen())),
          ),
          const SizedBox(height: 26),
          if (replays.isNotEmpty) ...[
            const SectionHeader(title: '다시보기', emoji: '▶️'),
            ...replays.map((l) => _ReplayCard(live: l)),
          ],
        ],
      ),
    );
  }
}

class _LiveNowCard extends StatelessWidget {
  const _LiveNowCard({required this.live});
  final LiveSession live;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B2F2B), Color(0xFF5A443D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.24),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.coral,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, size: 7, color: Colors.white),
                    SizedBox(width: 5),
                    Text(
                      'LIVE NOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.remove_red_eye_rounded,
                    size: 14,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${Fmt.count(live.viewers)}명 시청 중',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(live.emoji, style: const TextStyle(fontSize: 34)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  live.title.replaceFirst('🔴 ', ''),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    height: 1.35,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            ],
          ),
          if (live.note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              live.note,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 18),
          PillButton(
            label: '지금 참여하기',
            icon: Icons.live_tv_rounded,
            expanded: true,
            color: AppColors.coral,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('라이브 방송으로 연결합니다 🎥')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.live});
  final LiveSession live;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.lilacSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(live.emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  live.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${Fmt.dateTime(live.scheduledAt)} (${Fmt.relativeToNow(live.scheduledAt)})',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${Fmt.dateTime(live.scheduledAt)} 알림을 설정했어요 🔔',
                  ),
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.yellowSoft,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                size: 18,
                color: Color(0xFFD99A00),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplayCard extends StatelessWidget {
  const _ReplayCard({required this.live});
  final LiveSession live;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"${live.title}" 다시보기를 재생합니다 ▶️')),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 9),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.creamDeep,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 22,
                  color: AppColors.coral,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      live.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${Fmt.date(live.scheduledAt)} · ${Fmt.count(live.replayViews)}회 시청',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventShortcut extends StatelessWidget {
  const _EventShortcut({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: AppColors.yellowSoft,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            const Text('🎁', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '이벤트 & 굿즈',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF8A6200),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    '진행 중인 이벤트를 확인해보세요',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFFA97D1A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFD99A00),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
