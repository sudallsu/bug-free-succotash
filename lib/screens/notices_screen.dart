import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';

class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

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
          '공지사항 📢',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 17,
            color: AppColors.ink,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 26),
          children: state.notices
              .map(
                (n) => _NoticeTile(
                  notice: n,
                  unread: !state.readNoticeIds.contains(n.id),
                  onTap: () {
                    state.markNoticeRead(n.id);
                    _open(context, n);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _open(BuildContext context, Notice n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.62,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (context, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
          child: Column(
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
              const SizedBox(height: 22),
              Row(
                children: [
                  _categoryBadge(n.category),
                  const Spacer(),
                  Text(
                    Fmt.dateFull(n.createdAt),
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                n.title,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.35,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  n.body,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.75,
                    color: AppColors.inkSoft,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              PillButton(
                label: '확인',
                expanded: true,
                color: AppColors.creamDeep,
                textColor: AppColors.inkSoft,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryBadge(String category) {
    final map = {
      '중요': (AppColors.coral, Colors.white),
      '일정': (AppColors.skySoft, const Color(0xFF1B7FB8)),
      '굿즈': (AppColors.yellowSoft, const Color(0xFF9A6B00)),
      '안내': (AppColors.mintSoft, const Color(0xFF1C8F72)),
    };
    final (bg, fg) = map[category] ?? (AppColors.creamDeep, AppColors.inkSoft);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          color: fg,
        ),
      ),
    );
  }
}

class _NoticeTile extends StatelessWidget {
  const _NoticeTile({
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
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: notice.isPinned
              ? Border.all(color: AppColors.coral, width: 1.4)
              : Border.all(color: AppColors.line, width: 1.1),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (notice.isPinned) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.coral,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '📌 고정',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                ],
                Text(
                  notice.category,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.muted,
                  ),
                ),
                const Spacer(),
                Text(
                  Fmt.date(notice.createdAt),
                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                ),
                if (unread) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.coral,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 9),
            Text(
              notice.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              notice.body.replaceAll('\n', ' '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
