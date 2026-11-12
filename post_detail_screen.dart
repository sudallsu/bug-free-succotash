import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';

/// 글 상세 / 글 작성 (composeMode)
class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({
    super.key,
    required this.post,
    this.composeMode = false,
    this.composeVideoTitle,
  });

  final CommunityPost? post;
  final bool composeMode;
  final String? composeVideoTitle;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _bodyController = TextEditingController();
  final _commentController = TextEditingController();
  final _commentFocus = FocusNode();
  String _tag = '자유톡';
  bool _saving = false;

  static const _tags = ['자유톡', '감상', '질문', '정보'];

  @override
  void initState() {
    super.initState();
    if (widget.composeVideoTitle != null) _tag = '감상';
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _commentController.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.composeMode) return _buildCompose();
    return _buildDetail();
  }

  // ── 글 작성 화면 ──────────────────────────────────────
  Widget _buildCompose() {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.ink),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          '새 글 쓰기',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 17,
            color: AppColors.ink,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 사용자 정보
                    Consumer<AppState>(
                      builder: (context, state, _) => Row(
                        children: [
                          EmojiAvatar(emoji: state.profile.emoji, size: 42),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.profile.nickname,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              LevelBadge(level: state.profile.level),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // 태그 선택
                    const Text(
                      '주제',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags
                          .map(
                            (t) => CategoryChip(
                              label: t,
                              selected: _tag == t,
                              color: AppColors.mint,
                              onTap: () => setState(() => _tag = t),
                            ),
                          )
                          .toList(),
                    ),
                    if (widget.composeVideoTitle != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.yellowSoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.play_circle_fill_rounded,
                              size: 17,
                              color: Color(0xFFD99A00),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                widget.composeVideoTitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF8A6200),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    TextField(
                      controller: _bodyController,
                      maxLines: 10,
                      autofocus: true,
                      maxLength: 500,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.6,
                        color: AppColors.ink,
                      ),
                      decoration: const InputDecoration(
                        hintText: '팬들과 나누고 싶은 이야기를 적어주세요 💬',
                        counterStyle: TextStyle(
                          color: AppColors.muted,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Consumer<AppState>(
                builder: (context, state, _) => PillButton(
                  label: _saving ? '등록 중...' : '등록하기',
                  icon: Icons.send_rounded,
                  expanded: true,
                  onPressed: _saving
                      ? null
                      : () async {
                          final text = _bodyController.text.trim();
                          if (text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('내용을 입력해 주세요')),
                            );
                            return;
                          }
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          setState(() => _saving = true);
                          await state.createPost(body: text, tag: _tag);
                          if (!mounted) return;
                          setState(() => _saving = false);
                          navigator.pop();
                          messenger.showSnackBar(
                            const SnackBar(content: Text('글이 등록됐어요! +10P 🎉')),
                          );
                        },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 글 상세 화면 ──────────────────────────────────────
  Widget _buildDetail() {
    final state = context.watch<AppState>();
    final post = state.posts.firstWhere(
      (p) => p.id == widget.post!.id,
      orElse: () => widget.post!,
    );

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
          '팬 라운지',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: AppColors.ink,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 작성자
                    Row(
                      children: [
                        EmojiAvatar(emoji: post.emoji, size: 44),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.author,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  LevelBadge(level: post.level),
                                  const SizedBox(width: 6),
                                  Text(
                                    Fmt.dateTime(post.createdAt),
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.mintSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            post.tag,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1C8F72),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      post.body,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.7,
                        color: AppColors.ink,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 22),
                    // 좋아요
                    GestureDetector(
                      onTap: () => state.togglePostLike(post),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: post.likedByMe
                              ? const Color(0xFFFFE1DC)
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: post.likedByMe
                                ? AppColors.coral
                                : AppColors.line,
                            width: 1.3,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              post.likedByMe
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 17,
                              color: post.likedByMe
                                  ? AppColors.coral
                                  : AppColors.muted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '좋아요 ${post.likeCount}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: post.likedByMe
                                    ? AppColors.coral
                                    : AppColors.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Divider(color: AppColors.line),
                    const SizedBox(height: 18),
                    Text(
                      '댓글 ${post.comments.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (post.comments.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 26),
                        alignment: Alignment.center,
                        child: const Text(
                          '첫 댓글을 남겨보세요 🌱',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      ...post.comments.map((c) => _CommentTile(comment: c)),
                  ],
                ),
              ),
            ),
            // 댓글 입력
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      focusNode: _commentFocus,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendComment(state, post),
                      decoration: InputDecoration(
                        hintText: '댓글을 남겨보세요',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        isDense: true,
                        fillColor: AppColors.creamDeep,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendComment(state, post),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: AppColors.coral,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendComment(AppState state, CommunityPost post) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    _commentController.clear();
    _commentFocus.unfocus();
    await state.addComment(post, text);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('댓글이 등록됐어요 💬')));
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});
  final PostComment comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmojiAvatar(emoji: comment.emoji, size: 32),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.author,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      Fmt.date(comment.createdAt),
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  comment.body,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
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
