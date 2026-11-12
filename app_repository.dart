import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../data/demo_data.dart';
import '../models/models.dart';
import 'firebase_bootstrap.dart';

/// 데이터 저장소 인터페이스
/// ─ Firestore 모드와 로컬 모드가 동일한 API를 구현합니다.
abstract class AppRepository {
  bool get isCloud;

  Future<void> initialize();

  Future<ChannelProfile> getChannel();

  Future<List<VideoItem>> getVideos();
  Future<void> likeVideo(String videoId);

  Future<List<Notice>> getNotices();

  Future<List<CommunityPost>> getPosts();
  Future<CommunityPost> addPost({
    required String body,
    required String tag,
    String? videoId,
  });
  Future<CommunityPost> toggleLike(CommunityPost post);
  Future<CommunityPost> addComment(CommunityPost post, String body);

  Future<List<FanLetter>> getLetters();
  Future<FanLetter> sendLetter(String body);
  Future<FanLetter> markLetterRead(FanLetter letter);

  Future<List<LiveSession>> getLives();

  Future<List<EventItem>> getEvents();
  Future<EventItem> joinEvent(EventItem event);

  Future<FanProfile> getFanProfile();
  Future<FanProfile> updateFanProfile({String? nickname, String? emoji});
}

const _uuid = Uuid();

/// ─────────────────────────────────────────────────────────────
/// 로컬 저장소 (SharedPreferences + 메모리)
/// Firebase 설정이 없을 때 데모/오프라인 모드로 동작
/// ─────────────────────────────────────────────────────────────
class LocalRepository implements AppRepository {
  static const _kPosts = 'fh_posts';
  static const _kLetters = 'fh_letters';
  static const _kLikes = 'fh_liked_videos';
  static const _kEvents = 'fh_joined_events';
  static const _kProfile = 'fh_fan_profile';
  static const _kReadLetters = 'fh_read_letters';

  SharedPreferences? _prefs;
  List<CommunityPost> _posts = [];
  List<FanLetter> _letters = [];
  List<VideoItem> _videos = [];
  Set<String> _likedVideos = {};
  Set<String> _joinedEvents = {};
  Set<String> _readLetters = {};
  FanProfile _profile = DemoData.fanProfile;

  @override
  bool get isCloud => false;

  @override
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _videos = DemoData.videos();
    _posts = DemoData.posts();
    _letters = DemoData.letters();
    _likedVideos = (_prefs!.getStringList(_kLikes) ?? []).toSet();
    _joinedEvents = (_prefs!.getStringList(_kEvents) ?? []).toSet();
    _readLetters = (_prefs!.getStringList(_kReadLetters) ?? []).toSet();

    // 저장된 사용자 글/편지 복원 (덮어쓰기)
    _restorePosts();
    _restoreLetters();

    final profileRaw = _prefs!.getString(_kProfile);
    if (profileRaw != null) {
      try {
        _profile = FanProfile.fromMap(
          Map<String, dynamic>.from(jsonDecode(profileRaw) as Map),
        );
      } catch (_) {}
    }

    // 좋아요 상태 반영
    _videos = _videos
        .map(
          (v) => _likedVideos.contains(v.id)
              ? v.copyWith(likes: v.likes, views: v.views)
              : v,
        )
        .toList();
  }

  void _restorePosts() {
    final raw = _prefs!.getString(_kPosts);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List)
          .whereType<Map>()
          .map((e) => CommunityPost.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      // 사용자 작성 글을 맨 위에 병합
      _posts = [
        ...list,
        ..._posts.where((p) => !list.any((l) => l.id == p.id)),
      ];
    } catch (_) {}
  }

  Future<void> _persistPosts() async {
    final mine = _posts.where((p) => p.isMine).map((p) => p.toMap()).toList();
    await _prefs!.setString(_kPosts, jsonEncode(mine));
  }

  void _restoreLetters() {
    final raw = _prefs!.getString(_kLetters);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List)
          .whereType<Map>()
          .map((e) => FanLetter.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      _letters = [
        ...list,
        ..._letters.where((l) => !list.any((x) => x.id == l.id)),
      ];
    } catch (_) {}
  }

  Future<void> _persistLetters() async {
    final mine = _letters.where((l) => l.isMine).map((l) => l.toMap()).toList();
    await _prefs!.setString(_kLetters, jsonEncode(mine));
  }

  @override
  Future<ChannelProfile> getChannel() async => DemoData.channel;

  @override
  Future<List<VideoItem>> getVideos() async {
    final list = [..._videos]
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return list;
  }

  @override
  Future<void> likeVideo(String videoId) async {
    final idx = _videos.indexWhere((v) => v.id == videoId);
    if (idx < 0) return;
    final v = _videos[idx];
    final liked = _likedVideos.contains(videoId);
    if (liked) {
      _likedVideos.remove(videoId);
      _videos[idx] = v.copyWith(likes: v.likes - 1);
    } else {
      _likedVideos.add(videoId);
      _videos[idx] = v.copyWith(likes: v.likes + 1);
    }
    await _prefs!.setStringList(_kLikes, _likedVideos.toList());
  }

  bool isVideoLiked(String videoId) => _likedVideos.contains(videoId);

  @override
  Future<List<Notice>> getNotices() async {
    final list = [...DemoData.notices()]
      ..sort((a, b) {
        if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
        return b.createdAt.compareTo(a.createdAt);
      });
    return list;
  }

  @override
  Future<List<CommunityPost>> getPosts() async {
    final list = [..._posts]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<CommunityPost> addPost({
    required String body,
    required String tag,
    String? videoId,
  }) async {
    final post = CommunityPost(
      id: _uuid.v4(),
      author: _profile.nickname,
      emoji: _profile.emoji,
      level: _profile.level,
      body: body,
      createdAt: DateTime.now(),
      tag: tag,
      videoId: videoId,
      isMine: true,
    );
    _posts.insert(0, post);
    await _persistPosts();
    return post;
  }

  @override
  Future<CommunityPost> toggleLike(CommunityPost post) async {
    final idx = _posts.indexWhere((p) => p.id == post.id);
    if (idx < 0) return post;
    final p = _posts[idx];
    p.likedByMe = !p.likedByMe;
    p.likeCount += p.likedByMe ? 1 : -1;
    return p;
  }

  @override
  Future<CommunityPost> addComment(CommunityPost post, String body) async {
    final idx = _posts.indexWhere((p) => p.id == post.id);
    if (idx < 0) return post;
    final p = _posts[idx];
    p.comments = [
      ...p.comments,
      PostComment(
        id: _uuid.v4(),
        author: _profile.nickname,
        emoji: _profile.emoji,
        body: body,
        createdAt: DateTime.now(),
      ),
    ];
    if (p.isMine) await _persistPosts();
    return p;
  }

  @override
  Future<List<FanLetter>> getLetters() async {
    final list = [..._letters]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<FanLetter> sendLetter(String body) async {
    final letter = FanLetter(
      id: _uuid.v4(),
      from: _profile.nickname,
      emoji: _profile.emoji,
      body: body,
      createdAt: DateTime.now(),
      isMine: true,
      isRead: false,
    );
    _letters.insert(0, letter);
    await _persistLetters();
    return letter;
  }

  @override
  Future<FanLetter> markLetterRead(FanLetter letter) async {
    letter.isRead = true;
    _readLetters.add(letter.id);
    await _prefs!.setStringList(_kReadLetters, _readLetters.toList());
    return letter;
  }

  @override
  Future<List<LiveSession>> getLives() async {
    final list = [...DemoData.lives()];
    list.sort((a, b) {
      if (a.isLive != b.isLive) return a.isLive ? -1 : 1;
      if (a.isUpcoming != b.isUpcoming) return a.isUpcoming ? -1 : 1;
      return b.scheduledAt.compareTo(a.scheduledAt);
    });
    return list;
  }

  @override
  Future<List<EventItem>> getEvents() async {
    return DemoData.events()
        .map(
          (e) => _joinedEvents.contains(e.id)
              ? EventItem(
                  id: e.id,
                  title: e.title,
                  description: e.description,
                  emoji: e.emoji,
                  type: e.type,
                  startAt: e.startAt,
                  endAt: e.endAt,
                  participants: e.participants + 1,
                  linkLabel: '참여 완료',
                )
              : e,
        )
        .toList();
  }

  @override
  Future<EventItem> joinEvent(EventItem event) async {
    _joinedEvents.add(event.id);
    await _prefs!.setStringList(_kEvents, _joinedEvents.toList());
    return EventItem(
      id: event.id,
      title: event.title,
      description: event.description,
      emoji: event.emoji,
      type: event.type,
      startAt: event.startAt,
      endAt: event.endAt,
      participants: event.participants + 1,
      linkLabel: '참여 완료',
    );
  }

  @override
  Future<FanProfile> getFanProfile() async => _profile;

  @override
  Future<FanProfile> updateFanProfile({String? nickname, String? emoji}) async {
    _profile = _profile.copyWith(nickname: nickname, emoji: emoji);
    await _prefs!.setString(_kProfile, jsonEncode(_profile.toMap()));
    return _profile;
  }
}

/// ─────────────────────────────────────────────────────────────
/// Firestore 저장소 — Firebase 설정이 존재할 때 사용
/// 안내: 복합 인덱스가 필요한 쿼리를 피하고, 정렬은 메모리에서 수행합니다.
/// ─────────────────────────────────────────────────────────────
class FirestoreRepository implements AppRepository {
  FirebaseFirestore get _db => FirebaseBootstrap.db;

  @override
  bool get isCloud => true;

  Future<void> _seedIfEmpty(
    String collection,
    List<Map<String, dynamic>> docs,
    String idKey,
  ) async {
    try {
      final snap = await _db.collection(collection).limit(1).get();
      if (snap.docs.isNotEmpty) return;
      final batch = _db.batch();
      for (final d in docs) {
        final id = (d[idKey] ?? _uuid.v4()).toString();
        batch.set(_db.collection(collection).doc(id), d);
      }
      await batch.commit();
      if (kDebugMode) debugPrint('[Firestore] $collection 시드 완료');
    } catch (e) {
      if (kDebugMode) debugPrint('[Firestore] $collection 시드 실패: $e');
    }
  }

  @override
  Future<void> initialize() async {
    await _seedIfEmpty(
      'videos',
      DemoData.videos().map((e) => e.toMap()).toList(),
      'id',
    );
    await _seedIfEmpty(
      'notices',
      DemoData.notices().map((e) => e.toMap()).toList(),
      'id',
    );
    await _seedIfEmpty(
      'posts',
      DemoData.posts().map((e) => e.toMap()).toList(),
      'id',
    );
    await _seedIfEmpty(
      'letters',
      DemoData.letters().map((e) => e.toMap()).toList(),
      'id',
    );
    await _seedIfEmpty(
      'lives',
      DemoData.lives().map((e) => e.toMap()).toList(),
      'id',
    );
    await _seedIfEmpty(
      'events',
      DemoData.events().map((e) => e.toMap()).toList(),
      'id',
    );
    await _seedIfEmpty('app', [
      {'id': 'channel', ...DemoData.channel.toMap()},
    ], 'id');
  }

  Future<List<Map<String, dynamic>>> _all(String collection) async {
    try {
      final snap = await _db.collection(collection).get();
      return snap.docs.map((d) => {...d.data(), 'doc_id': d.id}).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[Firestore] $collection 읽기 실패: $e');
      return const [];
    }
  }

  @override
  Future<ChannelProfile> getChannel() async {
    try {
      final doc = await _db.collection('app').doc('channel').get();
      if (doc.exists) return ChannelProfile.fromMap(doc.data()!);
    } catch (_) {}
    return DemoData.channel;
  }

  @override
  Future<List<VideoItem>> getVideos() async {
    final raw = await _all('videos');
    if (raw.isEmpty) return DemoData.videos();
    final list = raw.map((m) => VideoItem.fromMap(m)).toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return list;
  }

  @override
  Future<void> likeVideo(String videoId) async {
    try {
      await _db.collection('videos').doc(videoId).update({
        'likes': FieldValue.increment(1),
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[Firestore] 좋아요 실패: $e');
    }
  }

  @override
  Future<List<Notice>> getNotices() async {
    final raw = await _all('notices');
    if (raw.isEmpty) return DemoData.notices();
    return raw.map((m) => Notice.fromMap(m)).toList()..sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  @override
  Future<List<CommunityPost>> getPosts() async {
    final raw = await _all('posts');
    if (raw.isEmpty) return DemoData.posts();
    return raw.map((m) => CommunityPost.fromMap(m)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<CommunityPost> addPost({
    required String body,
    required String tag,
    String? videoId,
  }) async {
    final profile = await getFanProfile();
    final post = CommunityPost(
      id: _uuid.v4(),
      author: profile.nickname,
      emoji: profile.emoji,
      level: profile.level,
      body: body,
      createdAt: DateTime.now(),
      tag: tag,
      videoId: videoId,
      isMine: true,
    );
    try {
      await _db.collection('posts').doc(post.id).set(post.toMap());
    } catch (e) {
      if (kDebugMode) debugPrint('[Firestore] 글 작성 실패: $e');
    }
    return post;
  }

  @override
  Future<CommunityPost> toggleLike(CommunityPost post) async {
    post.likedByMe = !post.likedByMe;
    post.likeCount += post.likedByMe ? 1 : -1;
    try {
      await _db.collection('posts').doc(post.id).update({
        'like_count': FieldValue.increment(post.likedByMe ? 1 : -1),
      });
    } catch (_) {}
    return post;
  }

  @override
  Future<CommunityPost> addComment(CommunityPost post, String body) async {
    final profile = await getFanProfile();
    final c = PostComment(
      id: _uuid.v4(),
      author: profile.nickname,
      emoji: profile.emoji,
      body: body,
      createdAt: DateTime.now(),
    );
    post.comments = [...post.comments, c];
    try {
      await _db.collection('posts').doc(post.id).update({
        'comments': post.comments.map((e) => e.toMap()).toList(),
      });
    } catch (_) {}
    return post;
  }

  @override
  Future<List<FanLetter>> getLetters() async {
    final raw = await _all('letters');
    if (raw.isEmpty) return DemoData.letters();
    return raw.map((m) => FanLetter.fromMap(m)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<FanLetter> sendLetter(String body) async {
    final profile = await getFanProfile();
    final letter = FanLetter(
      id: _uuid.v4(),
      from: profile.nickname,
      emoji: profile.emoji,
      body: body,
      createdAt: DateTime.now(),
      isMine: true,
    );
    try {
      await _db.collection('letters').doc(letter.id).set(letter.toMap());
    } catch (e) {
      if (kDebugMode) debugPrint('[Firestore] 편지 전송 실패: $e');
    }
    return letter;
  }

  @override
  Future<FanLetter> markLetterRead(FanLetter letter) async {
    letter.isRead = true;
    try {
      await _db.collection('letters').doc(letter.id).update({'is_read': true});
    } catch (_) {}
    return letter;
  }

  @override
  Future<List<LiveSession>> getLives() async {
    final raw = await _all('lives');
    final list =
        (raw.isEmpty
                ? DemoData.lives()
                : raw.map((m) => LiveSession.fromMap(m)).toList())
            .toList();
    list.sort((a, b) {
      if (a.isLive != b.isLive) return a.isLive ? -1 : 1;
      if (a.isUpcoming != b.isUpcoming) return a.isUpcoming ? -1 : 1;
      return b.scheduledAt.compareTo(a.scheduledAt);
    });
    return list;
  }

  @override
  Future<List<EventItem>> getEvents() async {
    final raw = await _all('events');
    if (raw.isEmpty) return DemoData.events();
    return raw.map((m) => EventItem.fromMap(m)).toList();
  }

  @override
  Future<EventItem> joinEvent(EventItem event) async {
    try {
      await _db.collection('events').doc(event.id).update({
        'participants': FieldValue.increment(1),
      });
    } catch (_) {}
    return EventItem(
      id: event.id,
      title: event.title,
      description: event.description,
      emoji: event.emoji,
      type: event.type,
      startAt: event.startAt,
      endAt: event.endAt,
      participants: event.participants + 1,
      linkLabel: '참여 완료',
    );
  }

  @override
  Future<FanProfile> getFanProfile() async {
    try {
      final doc = await _db.collection('app').doc('fan_profile').get();
      if (doc.exists) return FanProfile.fromMap(doc.data()!);
    } catch (_) {}
    return DemoData.fanProfile;
  }

  @override
  Future<FanProfile> updateFanProfile({String? nickname, String? emoji}) async {
    final current = await getFanProfile();
    final updated = current.copyWith(nickname: nickname, emoji: emoji);
    try {
      await _db
          .collection('app')
          .doc('fan_profile')
          .set(updated.toMap(), SetOptions(merge: true));
    } catch (_) {}
    return updated;
  }
}
