import 'package:intl/intl.dart';

class Fmt {
  static final _compact = NumberFormat.compact(locale: 'en_US');

  /// 1.2K / 3.4M 스타일
  static String count(int n) {
    if (n < 1000) return '$n';
    return _compact.format(n);
  }

  static String won(int n) => NumberFormat('#,###', 'ko_KR').format(n);

  static String date(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    if (d.year == now.year) return DateFormat('M월 d일', 'ko_KR').format(d);
    return DateFormat('yyyy.MM.dd', 'ko_KR').format(d);
  }

  static String dateFull(DateTime d) =>
      DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(d);

  static String time(DateTime d) => DateFormat('a h시 mm분', 'ko_KR').format(d);

  static String dateTime(DateTime d) =>
      DateFormat('M월 d일 a h:mm', 'ko_KR').format(d);

  static String dDay(DateTime end) {
    final now = DateTime.now();
    final days = end.difference(now).inDays;
    if (days < 0) return '종료';
    if (days == 0) return 'D-Day';
    return 'D-$days';
  }

  static String weekday(DateTime d) {
    const w = ['월', '화', '수', '목', '금', '토', '일'];
    return '${w[d.weekday - 1]}요일';
  }

  static String relativeToNow(DateTime d) {
    final diff = d.difference(DateTime.now());
    if (diff.isNegative) return date(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 후';
    if (diff.inHours < 24) return '${diff.inHours}시간 후';
    return '${diff.inDays}일 후';
  }
}
