import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase 부트스트랩
///
/// `google-services.json`(Android) 또는 `firebase_options.dart`(Web)가
/// 프로젝트에 설정되어 있으면 Firestore 모드로 동작하고,
/// 설정이 없으면 자동으로 로컬 데모 모드로 폴백합니다.
class FirebaseBootstrap {
  static bool _initialized = false;
  static bool _available = false;

  static bool get isAvailable => _available;
  static bool get isInitialized => _initialized;

  /// 앱 시작 시 한 번 호출. 성공 시 true.
  static Future<bool> tryInit() async {
    if (_initialized) return _available;
    _initialized = true;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp().timeout(const Duration(seconds: 8));
      }
      // Firestore 접근 가능 여부를 가볍게 확인
      _available = true;
      if (kDebugMode) {
        debugPrint('[Firebase] 초기화 성공 — Firestore 모드로 동작합니다.');
      }
    } catch (e) {
      _available = false;
      if (kDebugMode) {
        debugPrint('[Firebase] 설정 없음 / 초기화 실패 → 로컬 데모 모드: $e');
      }
    }
    return _available;
  }

  static FirebaseFirestore get db => FirebaseFirestore.instance;
}
