/// FanHub Archive — 데이터 모델
/// Firestore 문서(Map)와 안전하게 상호 변환되도록 방어적 파싱을 사용합니다.
library;

int _asInt(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

String _asString(dynamic v, [String fallback = '']) {
  if (v == null) return fallback;
  return v.toString();
}

bool _asBool(dynamic v, [bool fallback = false]) {
  if (v is bool) return v;
  if (v is String) return v.toLowerCase() == 'true';
  if (v is num) return v != 0;
  return fallback;
}

DateTime _asDate(dynamic v) {
  if (v is DateTime) return v;
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
  if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
  // Firestore Timestamp
  try {
    final dynamic ts = v;
    final dynamic d = ts.toDate();
    if (d is DateTime) return d;
  } catch (_) {}
  return DateTime.now();
}

List<String> _asStringList(dynamic v) {
  if (v is List) {
    return v.map((e) => e?.toString() ?? '').toList();
  }
  return const [];
}

class ChannelProfile {
  const ChannelProfile({
    required this.name,
    required this.handle,
    required this.tagline,
    required this.subscribers,
    required this.emoji,
    required this.videoCount,
    required this.bio,
  });

  final String name;
  final String handle;
  final String tagline;
  final int subscribers;
  final String emoji;
  final int videoCount;
  final String bio;

  factory ChannelProfile.fromMap(Map<String, dynamic> m) => ChannelProfile(
    name: _asString(m['name'], '채널'),
    handle: _asString(m['handle'], '@channel'),
    tagline: _asString(m['tagline']),
    subscribers: _asInt(m['subscribers']),
    emoji: _asString(m['emoji'], '🌷'),
    videoCount: _asInt(m['videoCount']),
    bio: _asString(m['bio']),
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'handle': handle,
    'tagline': tagline,
    'subscribers': subscribers,
    'emoji': emoji,
    'videoCount': videoCount,
    'bio': bio,
  };
}

class VideoItem {
  const VideoItem({
    required this.id,
    required this.title,
    required this.category,
    required this.emoji,
    required this.views,
    required this.likes,
    required this.comments,
    required this.durationSeconds,
    required this.publishedAt,
    required this.description,
    this.tags = const [],
    this.isFeatured = false,
  });

  final String id;
  final String title;
  final String category;
  final String emoji;
  final int views;
  final int likes;
  final int comments;
  final int durationSeconds;
  final DateTime publishedAt;
  final String description;
  final List<String> tags;
  final bool isFeatured;

  String get durationLabel {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  VideoItem copyWith({int? views, int? likes, int? comments}) => VideoItem(
    id: id,
    title: title,
    category: category,
    emoji: emoji,
    views: views ?? this.views,
    likes: likes ?? this.likes,
    comments: comments ?? this.comments,
    durationSeconds: durationSeconds,
    publishedAt: publishedAt,
    description: description,
    tags: tags,
    isFeatured: isFeatured,
  );

  factory VideoItem.fromMap(Map<String, dynamic> m) => VideoItem(
    id: _asString(m['id']),
    title: _asString(m['title'], '제목 없음'),
    category: _asString(m['category'], '일상'),
    emoji: _asString(m['emoji'], '🎬'),
    views: _asInt(m['views']),
    likes: _asInt(m['likes']),
    comments: _asInt(m['comments']),
    durationSeconds: _asInt(m['duration_seconds']),
    publishedAt: _asDate(m['published_at']),
    description: _asString(m['description']),
    tags: _asStringList(m['tags']),
    isFeatured: _asBool(m['is_featured']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'category': category,
    'emoji': emoji,
    'views': views,
    'likes': likes,
    'comments': comments,
    'duration_seconds': durationSeconds,
    'published_at': publishedAt.toIso8601String(),
    'description': description,
    'tags': tags,
    'is_featured': isFeatured,
  };
}

class Notice {
  const Notice({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.createdAt,
    this.isPinned = false,
  });

  final String id;
  final String title;
  final String body;
  final String category;
  final DateTime createdAt;
  final bool isPinned;

  factory Notice.fromMap(Map<String, dynamic> m) => Notice(
    id: _asString(m['id']),
    title: _asString(m['title']),
    body: _asString(m['body']),
    category: _asString(m['category'], '공지'),
    createdAt: _asDate(m['created_at']),
    isPinned: _asBool(m['is_pinned']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'category': category,
    'created_at': createdAt.toIso8601String(),
    'is_pinned': isPinned,
  };
}

class PostComment {
  PostComment({
    required this.id,
    required this.author,
    required this.emoji,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String author;
  final String emoji;
  final String body;
  final DateTime createdAt;

  factory PostComment.fromMap(Map<String, dynamic> m) => PostComment(
    id: _asString(m['id']),
    author: _asString(m['author'], '팬'),
    emoji: _asString(m['emoji'], '🐣'),
    body: _asString(m['body']),
    createdAt: _asDate(m['created_at']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'author': author,
    'emoji': emoji,
    'body': body,
    'created_at': createdAt.toIso8601String(),
  };
}

class CommunityPost {
  CommunityPost({
    required this.id,
    required this.author,
    required this.emoji,
    required this.level,
    required this.body,
    required this.createdAt,
    required this.tag,
    this.videoId,
    this.likeCount = 0,
    this.likedByMe = false,
    this.comments = const [],
    this.isMine = false,
  });

  final String id;
  final String author;
  final String emoji;
  final String level;
  final String body;
  final DateTime createdAt;
  final String tag;
  final String? videoId;
  int likeCount;
  bool likedByMe;
  List<PostComment> comments;
  final bool isMine;

  factory CommunityPost.fromMap(Map<String, dynamic> m) => CommunityPost(
    id: _asString(m['id']),
    author: _asString(m['author'], '팬'),
    emoji: _asString(m['emoji'], '🐣'),
    level: _asString(m['level'], 'Lv.1'),
    body: _asString(m['body']),
    createdAt: _asDate(m['created_at']),
    tag: _asString(m['tag'], '자유톡'),
    videoId: m['video_id'] == null ? null : _asString(m['video_id']),
    likeCount: _asInt(m['like_count']),
    likedByMe: _asBool(m['liked_by_me']),
    comments: (m['comments'] is List)
        ? (m['comments'] as List)
              .whereType<Map>()
              .map((e) => PostComment.fromMap(Map<String, dynamic>.from(e)))
              .toList()
        : const [],
    isMine: _asBool(m['is_mine']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'author': author,
    'emoji': emoji,
    'level': level,
    'body': body,
    'created_at': createdAt.toIso8601String(),
    'tag': tag,
    'video_id': videoId,
    'like_count': likeCount,
    'liked_by_me': likedByMe,
    'comments': comments.map((e) => e.toMap()).toList(),
    'is_mine': isMine,
  };
}

class FanLetter {
  FanLetter({
    required this.id,
    required this.from,
    required this.emoji,
    required this.body,
    required this.createdAt,
    this.heartsWith = 0,
    this.isRead = false,
    this.isMine = false,
  });

  final String id;
  final String from;
  final String emoji;
  final String body;
  final DateTime createdAt;
  final int heartsWith;
  bool isRead;
  final bool isMine;

  factory FanLetter.fromMap(Map<String, dynamic> m) => FanLetter(
    id: _asString(m['id']),
    from: _asString(m['from'], '익명 팬'),
    emoji: _asString(m['emoji'], '💌'),
    body: _asString(m['body']),
    createdAt: _asDate(m['created_at']),
    heartsWith: _asInt(m['hearts']),
    isRead: _asBool(m['is_read']),
    isMine: _asBool(m['is_mine']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'from': from,
    'emoji': emoji,
    'body': body,
    'created_at': createdAt.toIso8601String(),
    'hearts': heartsWith,
    'is_read': isRead,
    'is_mine': isMine,
  };
}

class LiveSession {
  const LiveSession({
    required this.id,
    required this.title,
    required this.scheduledAt,
    required this.emoji,
    required this.category,
    this.isLive = false,
    this.viewers = 0,
    this.replayViews = 0,
    this.note = '',
  });

  final String id;
  final String title;
  final DateTime scheduledAt;
  final String emoji;
  final String category;
  final bool isLive;
  final int viewers;
  final int replayViews;
  final String note;

  bool get isUpcoming => !isLive && scheduledAt.isAfter(DateTime.now());

  factory LiveSession.fromMap(Map<String, dynamic> m) => LiveSession(
    id: _asString(m['id']),
    title: _asString(m['title']),
    scheduledAt: _asDate(m['scheduled_at']),
    emoji: _asString(m['emoji'], '🎥'),
    category: _asString(m['category'], '라이브'),
    isLive: _asBool(m['is_live']),
    viewers: _asInt(m['viewers']),
    replayViews: _asInt(m['replay_views']),
    note: _asString(m['note']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'scheduled_at': scheduledAt.toIso8601String(),
    'emoji': emoji,
    'category': category,
    'is_live': isLive,
    'viewers': viewers,
    'replay_views': replayViews,
    'note': note,
  };
}

class EventItem {
  const EventItem({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.type,
    required this.startAt,
    required this.endAt,
    required this.participants,
    this.linkLabel = '참여하기',
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
  final String type; // 이벤트 / 굿즈
  final DateTime startAt;
  final DateTime endAt;
  final int participants;
  final String linkLabel;

  bool get isOngoing => DateTime.now().isBefore(endAt);

  factory EventItem.fromMap(Map<String, dynamic> m) => EventItem(
    id: _asString(m['id']),
    title: _asString(m['title']),
    description: _asString(m['description']),
    emoji: _asString(m['emoji'], '🎁'),
    type: _asString(m['type'], '이벤트'),
    startAt: _asDate(m['start_at']),
    endAt: _asDate(m['end_at']),
    participants: _asInt(m['participants']),
    linkLabel: _asString(m['link_label'], '참여하기'),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'emoji': emoji,
    'type': type,
    'start_at': startAt.toIso8601String(),
    'end_at': endAt.toIso8601String(),
    'participants': participants,
    'link_label': linkLabel,
  };
}

class FanProfile {
  const FanProfile({
    required this.nickname,
    required this.emoji,
    required this.level,
    required this.points,
    required this.joinedAt,
  });

  final String nickname;
  final String emoji;
  final String level;
  final int points;
  final DateTime joinedAt;

  FanProfile copyWith({String? nickname, String? emoji}) => FanProfile(
    nickname: nickname ?? this.nickname,
    emoji: emoji ?? this.emoji,
    level: level,
    points: points,
    joinedAt: joinedAt,
  );

  factory FanProfile.fromMap(Map<String, dynamic> m) => FanProfile(
    nickname: _asString(m['nickname'], '새로운 팬'),
    emoji: _asString(m['emoji'], '🐣'),
    level: _asString(m['level'], 'Lv.1 새싹팬'),
    points: _asInt(m['points']),
    joinedAt: _asDate(m['joined_at']),
  );

  Map<String, dynamic> toMap() => {
    'nickname': nickname,
    'emoji': emoji,
    'level': level,
    'points': points,
    'joined_at': joinedAt.toIso8601String(),
  };
}
