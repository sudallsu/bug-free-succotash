import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final events = state.events;
    final ongoing = events.where((e) => e.isOngoing).toList();
    final ended = events.where((e) => !e.isOngoing).toList();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: AppColors.ink,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          '이벤트 & 굿즈 🎁',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 17,
            color: AppColors.ink,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          children: [
            if (ongoing.isNotEmpty) ...[
              const SectionHeader(title: '진행 중', emoji: '🔥'),
              ...ongoing.map(
                (e) => _EventCard(event: e, onJoin: () => state.joinEvent(e)),
              ),
              const SizedBox(height: 18),
            ],
            if (ended.isNotEmpty) ...[
              const SectionHeader(title: '종료된 이벤트', emoji: '🗂'),
              ...ended.map((e) => _EventCard(event: e, onJoin: null)),
            ],
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, this.onJoin});
  final EventItem event;
  final VoidCallback? onJoin;

  Color get _accent => event.type == '굿즈' ? AppColors.yellow : AppColors.coral;

  Color get _soft =>
      event.type == '굿즈' ? AppColors.yellowSoft : const Color(0xFFFFE1DC);

  @override
  Widget build(BuildContext context) {
    final joined = event.linkLabel == '참여 완료';
    final ongoing = event.isOngoing;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _soft,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(event.emoji, style: const TextStyle(fontSize: 23)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _soft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            event.type,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: _accent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: ongoing
                                ? AppColors.mintSoft
                                : AppColors.creamDeep,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            ongoing ? Fmt.dDay(event.endAt) : '종료',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: ongoing
                                  ? const Color(0xFF1C8F72)
                                  : AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.35,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event.description,
            style: const TextStyle(
              fontSize: 12,
              height: 1.6,
              color: AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              const Icon(
                Icons.people_alt_rounded,
                size: 14,
                color: AppColors.muted,
              ),
              const SizedBox(width: 4),
              Text(
                '${Fmt.count(event.participants)}명 참여',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),
              const Spacer(),
              if (ongoing)
                PillButton(
                  label: joined ? '참여 완료 ✓' : event.linkLabel,
                  height: 38,
                  color: joined ? AppColors.creamDeep : _accent,
                  textColor: joined ? AppColors.muted : Colors.white,
                  onPressed: joined ? null : onJoin,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
