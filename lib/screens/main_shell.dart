import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'archive_screen.dart';
import 'community_screen.dart';
import 'home_screen.dart';
import 'letters_screen.dart';
import 'live_screen.dart';
import 'my_page_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _navigate(int i) => setState(() => _index = i);

  static const _tabs = [
    (Icons.home_rounded, Icons.home_outlined, '홈'),
    (Icons.video_library_rounded, Icons.video_library_outlined, '아카이브'),
    (Icons.forum_rounded, Icons.forum_outlined, '라운지'),
    (Icons.live_tv_rounded, Icons.live_tv_outlined, '라이브'),
    (Icons.person_rounded, Icons.person_outline_rounded, '마이'),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.loading) {
      return const Scaffold(
        backgroundColor: AppColors.cream,
        body: LoadingView(message: '팬허브를 불러오는 중...'),
      );
    }
    if (state.error != null) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        body: EmptyState(
          emoji: '😢',
          title: '문제가 발생했어요',
          message: state.error,
          actionLabel: '다시 시도',
          onAction: state.load,
        ),
      );
    }

    final screens = [
      HomeScreen(onNavigate: _navigate),
      const ArchiveScreen(),
      const CommunityScreen(),
      const LiveScreen(),
      const MyPageScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.cream,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _index, children: screens),
      ),
      floatingActionButton: _index == 0
          ? _MailFab(
              count: state.unreadLetterCount,
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const LettersScreen())),
            )
          : null,
      bottomNavigationBar: _BottomBar(
        index: _index,
        tabs: _tabs,
        onTap: _navigate,
      ),
    );
  }
}

class _MailFab extends StatelessWidget {
  const _MailFab({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.coral,
          shape: BoxShape.circle,
          boxShadow: AppShadows.tinted(AppColors.coral),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.mail_rounded, color: Colors.white, size: 24),
            if (count > 0)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  constraints: const BoxConstraints(
                    minWidth: 15,
                    minHeight: 15,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.yellow,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.coral, width: 1.4),
                  ),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 8,
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

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.index,
    required this.tabs,
    required this.onTap,
  });

  final int index;
  final List<(IconData, IconData, String)> tabs;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.only(bottom: bottom > 0 ? bottom : 12, top: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final (activeIcon, inactiveIcon, label) = tabs[i];
          final selected = i == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: EdgeInsets.symmetric(
                      horizontal: selected ? 15 : 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFFFE1DC)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(
                      selected ? activeIcon : inactiveIcon,
                      size: 21,
                      color: selected ? AppColors.coral : AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                      color: selected ? AppColors.coral : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
