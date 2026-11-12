import 'package:flutter/foundation.dart';

import '../data/demo_data.dart';
import '../models/models.dart';
import '../services/app_repository.dart';

/// 전역 앱 상태 — 리포지토리에서 데이터를 불러와 화면에 제공합니다.
class AppState extends ChangeNotifier {
  AppState(this._repo);

  final AppRepository _repo;
  AppRepository get repo => _repo;
  bool get isCloud => _repo.isCloud;

  bool _loading = true;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  ChannelProfile _channel = DemoData.channel;
  ChannelProfile get channel => _channel;

  List<VideoItem> _videos = [];
  List<VideoItem> get videos => _videos;

  List<Notice> _notices = [];
  List<Notice> get notices => _notices;

  List<CommunityPost> _posts = [];
  List<CommunityPost> get posts => _posts;

  List<FanLetter> _letters = [];
  List<FanLetter> get letters => _letters;

  List<LiveSession> _lives = [];
  List<LiveSession> get lives => _lives;

  List<EventItem> _events = [];
  List<EventItem> get events => _events;

  FanProfile _profile = DemoData.fanProfile;
  FanProfile get profile => _profile;

  final Set<String> _readNoticeIds = {};
  Set<String> get readNoticeIds => _readNoticeIds;

  // ── 파생 값 ──────────────────────────────────────────────
  VideoItem? get featuredVideo {
    if (_videos.isEmpty) return null;
    final feat = _videos.where((v) => v.isFeatured).toList();
    return feat.isNotEmpty ? feat.first : _videos.first;
  }

  List<String> get categories {
    final set = <String>{};
    for (final v in _videos) {
      set.add(v.category);
    }
    final list = set.toList();
    list.sort();
    return ['전체', ...list];
  }

  int get unreadLetterCount => _letters.where((l) => !l.isRead).length;

  LiveSession? get activeLive {
    final l = _lives.where((e) => e.isLive).toList();
    return l.isEmpty ? null : l.first;
  }

  List<LiveSession> get upcomingLives =>
      _lives.where((e) => e.isUpcoming).toList();

  List<LiveSession> get replayLives =>
      _lives.where((e) => !e.isLive && !e.isUpcoming).toList();

  List<Notice> get pinnedNotices => _notices.where((n) => n.isPinned).toList();

  // ── 초기화 ──────────────────────────────────────────────
  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.initialize();
      final results = await Future.wait([
        _repo.getChannel(),
        _repo.getVideos(),
        _repo.getNotices(),
        _repo.getPosts(),
        _repo.getLetters(),
        _repo.getLives(),
        _repo.getEvents(),
        _repo.getFanProfile(),
      ]);
      _channel = results[0] as ChannelProfile;
      _videos = results[1] as List<VideoItem>;
      _notices = results[2] as List<Notice>;
      _posts = results[3] as List<CommunityPost>;
      _letters = results[4] as List<FanLetter>;
      _lives = results[5] as List<LiveSession>;
      _events = results[6] as List<EventItem>;
      _profile = results[7] as FanProfile;
    } catch (e) {
      _error = '데이터를 불러오지 못했어요. 다시 시도해 주세요.';
      if (kDebugMode) debugPrint('[AppState] 로드 실패: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshVideos() async {
    _videos = await _repo.getVideos();
    notifyListeners();
  }

  // ── 액션 ────────────────────────────────────────────────
  Future<void> likeVideo(String videoId) async {
    final idx = _videos.indexWhere((v) => v.id == videoId);
    if (idx < 0) return;
    final liked = _likedVideoIds.contains(videoId);
    if (liked) {
      _likedVideoIds.remove(videoId);
      _videos[idx] = _videos[idx].copyWith(likes: _videos[idx].likes - 1);
    } else {
      _likedVideoIds.add(videoId);
      _videos[idx] = _videos[idx].copyWith(likes: _videos[idx].likes + 1);
    }
    notifyListeners();
    await _repo.likeVideo(videoId);
  }

  final Set<String> _likedVideoIds = {};
  bool isVideoLiked(String id) =>
      _likedVideoIds.contains(id) ||
      (_repo is LocalRepository && _repo.isVideoLiked(id));

  Future<void> markNoticeRead(String id) async {
    if (_readNoticeIds.contains(id)) return;
    _readNoticeIds.add(id);
    notifyListeners();
  }

  Future<CommunityPost> createPost({
    required String body,
    required String tag,
    String? videoId,
  }) async {
    final post = await _repo.addPost(body: body, tag: tag, videoId: videoId);
    _posts = [post, ..._posts];
    _profile = FanProfile(
      nickname: _profile.nickname,
      emoji: _profile.emoji,
      level: _profile.level,
      points: _profile.points + 10,
      joinedAt: _profile.joinedAt,
    );
    notifyListeners();
    return post;
  }

  Future<void> togglePostLike(CommunityPost post) async {
    await _repo.toggleLike(post);
    notifyListeners();
  }

  Future<void> addComment(CommunityPost post, String body) async {
    await _repo.addComment(post, body);
    notifyListeners();
  }

  Future<FanLetter> sendLetter(String body) async {
    final letter = await _repo.sendLetter(body);
    _letters = [letter, ..._letters];
    notifyListeners();
    return letter;
  }

  Future<void> markLetterRead(FanLetter letter) async {
    if (letter.isRead) return;
    await _repo.markLetterRead(letter);
    notifyListeners();
  }

  Future<void> joinEvent(EventItem event) async {
    final updated = await _repo.joinEvent(event);
    _events = _events.map((e) => e.id == event.id ? updated : e).toList();
    notifyListeners();
  }

  Future<void> updateProfile({String? nickname, String? emoji}) async {
    _profile = await _repo.updateFanProfile(nickname: nickname, emoji: emoji);
    notifyListeners();
  }
}
