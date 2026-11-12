import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';

class LettersScreen extends StatelessWidget {
  const LettersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final letters = state.letters;

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
          '팬 레터 💌',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 17,
            color: AppColors.ink,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.coral),
            onPressed: () => _openComposer(context),
          ),
        ],
      ),
      body: SafeArea(
        child: letters.isEmpty
            ? const EmptyState(
                emoji: '💌',
                title: '아직 편지가 없어요',
                message: '첫 번째 마음을 전해보세요.',
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.yellowSoft,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Text('💌', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '팬 여러분이 보내준 마음이에요. 읽지 않은 편지 ${state.unreadLetterCount}통',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8A6200),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...letters.map(
                    (l) => _LetterCard(
                      letter: l,
                      onTap: () {
                        state.markLetterRead(l);
                        _showLetter(context, l);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _openComposer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _LetterComposer(),
    );
  }

  void _showLetter(BuildContext context, FanLetter letter) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 26),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  EmojiAvatar(emoji: letter.emoji, size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          letter.from,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          Fmt.dateTime(letter.createdAt),
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text('💌', style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  letter.body,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.7,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    size: 15,
                    color: AppColors.coral,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${letter.heartsWith}명이 함께 공감했어요',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              PillButton(
                label: '닫기',
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
}

class _LetterCard extends StatelessWidget {
  const _LetterCard({required this.letter, required this.onTap});
  final FanLetter letter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: letter.isRead ? AppColors.white : const Color(0xFFFFFDF7),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: letter.isRead ? AppColors.line : AppColors.yellow,
            width: letter.isRead ? 1.1 : 1.5,
          ),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                EmojiAvatar(emoji: letter.emoji, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            letter.from,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          if (letter.isMine) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              size: 12,
                              color: AppColors.sky,
                            ),
                          ],
                          if (!letter.isRead) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.coral,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Fmt.date(letter.createdAt),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.favorite_rounded,
                  size: 13,
                  color: AppColors.coral,
                ),
                const SizedBox(width: 3),
                Text(
                  '${letter.heartsWith}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.coral,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            Text(
              letter.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.55,
                color: AppColors.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LetterComposer extends StatefulWidget {
  const _LetterComposer();

  @override
  State<_LetterComposer> createState() => _LetterComposerState();
}

class _LetterComposerState extends State<_LetterComposer> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(22, 20, 22, 20 + bottom),
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
          Row(
            children: [
              const Text('💌', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 9),
              Text(
                '팬 레터 보내기',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '크리에이터에게 전하고 싶은 마음을 적어주세요.',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 6,
            maxLength: 400,
            autofocus: true,
            style: const TextStyle(fontSize: 14, height: 1.6),
            decoration: const InputDecoration(
              hintText: '예) 영상 덕분에 힘을 냈어요! 앞으로도 응원할게요 🌷',
              counterStyle: TextStyle(fontSize: 10, color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 12),
          Consumer<AppState>(
            builder: (context, state, _) => PillButton(
              label: _sending ? '보내는 중...' : '편지 보내기',
              icon: Icons.send_rounded,
              expanded: true,
              onPressed: _sending
                  ? null
                  : () async {
                      final text = _controller.text.trim();
                      if (text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('내용을 입력해 주세요')),
                        );
                        return;
                      }
                      setState(() => _sending = true);
                      await state.sendLetter(text);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('편지가 전달됐어요 💌 감사합니다!')),
                      );
                    },
            ),
          ),
        ],
      ),
    );
  }
}
