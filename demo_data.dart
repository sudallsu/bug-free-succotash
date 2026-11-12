import '../models/models.dart';

/// 데모 시드 데이터 — 실제 서비스에서는 Firestore/백엔드가 이 역할을 합니다.
class DemoData {
  static DateTime _daysAgo(int d) => DateTime.now().subtract(Duration(days: d));
  static DateTime _hoursAgo(int h) =>
      DateTime.now().subtract(Duration(hours: h));
  static DateTime _inDays(int d) => DateTime.now().add(Duration(days: d));

  static const ChannelProfile channel = ChannelProfile(
    name: '봄날의 하루',
    handle: '@bomnal_day',
    tagline: '일상을 기록하고, 팬들과 나눕니다 🌷',
    subscribers: 248000,
    emoji: '🌷',
    videoCount: 184,
    bio:
        '브이로그 · 먹방 · Q&A를 올리는 평범한 유튜버예요. '
        '이 공간은 우리 팬들이 함께 만드는 아카이브입니다. '
        '영상도, 사진도, 편지도 전부 여기에 쌓여요 💌',
  );

  static List<VideoItem> videos() => [
    VideoItem(
      id: 'v1',
      title: '새벽 4시에 시작하는 하루 | 조용한 브이로그',
      category: '브이로그',
      emoji: '🌅',
      views: 412000,
      likes: 38200,
      comments: 1240,
      durationSeconds: 742,
      publishedAt: _daysAgo(1),
      description: '해 뜨기 전에 일어나서 하루를 시작해봤어요. 커피 한 잔과 함께 🍵',
      tags: ['브이로그', '새벽', '루틴'],
      isFeatured: true,
    ),
    VideoItem(
      id: 'v2',
      title: '팬들이 보낸 질문 100개 답변합니다',
      category: 'Q&A',
      emoji: '💬',
      views: 289000,
      likes: 24100,
      comments: 2130,
      durationSeconds: 1284,
      publishedAt: _daysAgo(4),
      description: '댓글로 받은 질문들 진짜 다 답했어요. 마지막 질문은 반전 있음 😳',
      tags: ['Q&A', '소통', '진솔'],
    ),
    VideoItem(
      id: 'v3',
      title: '하루에 3만원으로 먹방 도전!',
      category: '먹방',
      emoji: '🍜',
      views: 523000,
      likes: 41000,
      comments: 1870,
      durationSeconds: 998,
      publishedAt: _daysAgo(7),
      description: '예산 안에서 최대한 많이 먹어보기. 결과는 영상에서 확인!',
      tags: ['먹방', '예산', '도전'],
    ),
    VideoItem(
      id: 'v4',
      title: '방 정리하면서 옛날 물건 다 꺼내봄',
      category: '일상',
      emoji: '📦',
      views: 176000,
      likes: 15400,
      comments: 640,
      durationSeconds: 845,
      publishedAt: _daysAgo(10),
      description: '10년 전 물건 나오면 진짜 추억 여행 시작입니다.',
      tags: ['일상', '정리', '추억'],
    ),
    VideoItem(
      id: 'v5',
      title: '밤 11시에 갑자기 떠난 즉흥 여행',
      category: '브이로그',
      emoji: '🚗',
      views: 358000,
      likes: 29800,
      comments: 1120,
      durationSeconds: 1420,
      publishedAt: _daysAgo(14),
      description: '충동적으로 떠난 여행인데 인생 최고의 밤이었습니다.',
      tags: ['여행', '즉흥', '브이로그'],
    ),
    VideoItem(
      id: 'v6',
      title: '구독자와 함께하는 실시간 게임 대결',
      category: '게임',
      emoji: '🎮',
      views: 264000,
      likes: 22100,
      comments: 3410,
      durationSeconds: 2160,
      publishedAt: _daysAgo(18),
      description: '구독자분들이랑 같이 게임했어요. 다음엔 더 많이 모여요!',
      tags: ['게임', '실시간', '구독자'],
    ),
    VideoItem(
      id: 'v7',
      title: '30일 동안 매일 운동한 결과',
      category: '챌린지',
      emoji: '🏃',
      views: 445000,
      likes: 36900,
      comments: 1580,
      durationSeconds: 1120,
      publishedAt: _daysAgo(21),
      description: '진짜 힘들었지만 해냈습니다. 몸도 마음도 달라졌어요.',
      tags: ['챌린지', '운동', '30일'],
    ),
    VideoItem(
      id: 'v8',
      title: '조용한 밤, 기타 치면서 노래 부르기',
      category: '음악',
      emoji: '🎸',
      views: 198000,
      likes: 31200,
      comments: 890,
      durationSeconds: 512,
      publishedAt: _daysAgo(25),
      description: '늦은 밤에 혼자 부르는 노래. 편하게 들어주세요 🎵',
      tags: ['음악', '기타', '자작곡'],
    ),
  ];

  static List<Notice> notices() => [
    Notice(
      id: 'n1',
      title: '📢 팬 아카이브 앱이 열렸어요!',
      body:
          '드디어 우리 팬들만의 공간이 생겼습니다.\n\n'
          '영상 아카이브, 팬 게시판, 팬 레터, 라이브 일정까지\n'
          '모든 소식을 이 앱에서 가장 먼저 확인하실 수 있어요.\n\n'
          '앞으로 이 공간에서 많이 만나요 💌',
      category: '중요',
      createdAt: _hoursAgo(6),
      isPinned: true,
    ),
    Notice(
      id: 'n2',
      title: '이번 주 라이브 일정 안내',
      body:
          '이번 주 금요일 저녁 8시, 라이브로 만나요!\n\n'
          '주제: 팬레터 읽기 + 즉석 Q&A\n'
          '참여하시면 실시간으로 답변해드립니다 🎥',
      category: '일정',
      createdAt: _daysAgo(2),
    ),
    Notice(
      id: 'n3',
      title: '겨울 굿즈 1차 예약 판매 시작',
      body:
          '한정판 겨울 굿즈 예약을 시작합니다.\n\n'
          '· 머그컵 + 스티커 세트\n'
          '· 후드 담요\n'
          '· 포토카드 4종\n\n'
          '자세한 내용은 이벤트/굿즈 탭에서 확인해주세요.',
      category: '굿즈',
      createdAt: _daysAgo(5),
    ),
    Notice(
      id: 'n4',
      title: '커뮤니티 이용 규칙 안내',
      body:
          '우리 공간이 오래 즐거울 수 있도록 부탁드려요.\n\n'
          '1. 서로 존중하는 말로 대화해요\n'
          '2. 개인정보는 올리지 않아요\n'
          '3. 광고/홍보는 자제해 주세요\n\n'
          '위 규칙을 지켜주시는 팬분들께 늘 감사해요 🌷',
      category: '안내',
      createdAt: _daysAgo(9),
    ),
  ];

  static List<CommunityPost> posts() => [
    CommunityPost(
      id: 'p1',
      author: '복숭아소다',
      emoji: '🍑',
      level: 'Lv.7 단골팬',
      body: '새벽 브이로그 보고 진짜 힘냈어요… 저도 내일부터 새벽 루틴 도전해봅니다 ☀️ 모두 화이팅!',
      createdAt: _hoursAgo(2),
      tag: '자유톡',
      videoId: 'v1',
      likeCount: 128,
      comments: [
        PostComment(
          id: 'c1',
          author: '초코우유',
          emoji: '🐰',
          body: '저도 같이 도전해요!!',
          createdAt: _hoursAgo(1),
        ),
        PostComment(
          id: 'c2',
          author: '봄날의 하루',
          emoji: '🌷',
          body: '다들 잘하고 있어요 👏',
          createdAt: _hoursAgo(1),
        ),
      ],
    ),
    CommunityPost(
      id: 'p2',
      author: '구름빵',
      emoji: '☁️',
      level: 'Lv.4 열혈팬',
      body: 'Q&A 영상에서 제 질문이 나왔어요!!! 소리 질렀습니다 😭😭 평생 기억할 것 같아요',
      createdAt: _hoursAgo(9),
      tag: '감상',
      videoId: 'v2',
      likeCount: 341,
      comments: [
        PostComment(
          id: 'c3',
          author: '하루팬',
          emoji: '🌻',
          body: '축하드려요!! 부럽습니다',
          createdAt: _hoursAgo(8),
        ),
      ],
    ),
    CommunityPost(
      id: 'p3',
      author: '민트초코',
      emoji: '🍃',
      level: 'Lv.2 새싹팬',
      body: '먹방 영상 보다가 배고파서 새벽에 라면 끓였습니다… 이게 맞나요 ㅋㅋㅋ',
      createdAt: _daysAgo(1),
      tag: '자유톡',
      videoId: 'v3',
      likeCount: 87,
      comments: [],
    ),
    CommunityPost(
      id: 'p4',
      author: '별하',
      emoji: '⭐',
      level: 'Lv.5 충성팬',
      body: '이 앱 진짜 잘 만들었네요. 영상 다시 보기 편하고 팬레터도 쓸 수 있어서 너무 좋아요 💌',
      createdAt: _daysAgo(2),
      tag: '자유톡',
      likeCount: 203,
      comments: [],
    ),
    CommunityPost(
      id: 'p5',
      author: '달빛',
      emoji: '🌙',
      level: 'Lv.3 팬',
      body: '기타 영상 들으면서 잠들었어요. 목소리가 너무 좋아요… 자작곡 앨범 내주세요 🙏',
      createdAt: _daysAgo(3),
      tag: '감상',
      videoId: 'v8',
      likeCount: 156,
      comments: [],
    ),
  ];

  static List<FanLetter> letters() => [
    FanLetter(
      id: 'l1',
      from: '복숭아소다',
      emoji: '🍑',
      body:
          '항상 좋은 영상 감사해요. 힘들 때마다 이 채널 보고 다시 힘냅니다. '
          '앞으로도 오래오래 함께하고 싶어요 🌷',
      createdAt: _hoursAgo(3),
      heartsWith: 42,
      isRead: true,
    ),
    FanLetter(
      id: 'l2',
      from: '구름빵',
      emoji: '☁️',
      body:
          'Q&A 영상에서 제 질문을 읽어주셔서 정말 감동했어요. '
          '그날 하루종일 웃었습니다. 감사합니다!',
      createdAt: _hoursAgo(14),
      heartsWith: 31,
      isRead: true,
    ),
    FanLetter(
      id: 'l3',
      from: '민트초코',
      emoji: '🍃',
      body:
          '새벽 브이로그 정말 좋았어요. 저도 새벽 루틴 시작해봤는데 '
          '생각보다 하루가 길어져서 좋더라고요!',
      createdAt: _daysAgo(1),
      heartsWith: 25,
      isRead: false,
    ),
    FanLetter(
      id: 'l4',
      from: '별하',
      emoji: '⭐',
      body:
          '30일 운동 챌린지 영상 보고 저도 같이 30일 도전 중이에요. '
          '지금 12일째! 같이 가는 느낌이라 포기 안 하게 됩니다 💪',
      createdAt: _daysAgo(2),
      heartsWith: 58,
      isRead: false,
    ),
    FanLetter(
      id: 'l5',
      from: '달빛',
      emoji: '🌙',
      body:
          '늦은 밤 기타 영상은 저한테는 진짜 위로예요. '
          '잠 안 올 때마다 듣습니다. 다음 곡도 기대할게요 🎸',
      createdAt: _daysAgo(3),
      heartsWith: 19,
      isRead: false,
    ),
    FanLetter(
      id: 'l6',
      from: '하루팬',
      emoji: '🌻',
      body:
          '처음 댓글 달았을 때 답장해주셔서 팬 됐어요. '
          '이제는 하루에 한 번씩 채널 들어오는 게 습관이 됐습니다.',
      createdAt: _daysAgo(4),
      heartsWith: 37,
      isRead: true,
    ),
  ];

  static List<LiveSession> lives() => [
    LiveSession(
      id: 'lv0',
      title: '🔴 지금 라이브! 팬레터 읽으며 수다떨기',
      scheduledAt: _hoursAgo(1),
      emoji: '💌',
      category: '라이브',
      isLive: true,
      viewers: 3420,
      note: '실시간 채팅 참여하고 질문 남겨주세요!',
    ),
    LiveSession(
      id: 'lv1',
      title: '금요일 저녁 8시 | 즉석 Q&A 라이브',
      scheduledAt: _inDays(2),
      emoji: '🎤',
      category: '라이브',
      note: '궁금한 것 미리 커뮤니티에 남겨주세요!',
    ),
    LiveSession(
      id: 'lv2',
      title: '주말 아침 | 커피 타임 브이로그 라이브',
      scheduledAt: _inDays(5),
      emoji: '☕',
      category: '라이브',
      note: '편하게 커피 마시면서 얘기해요 ☕',
    ),
    LiveSession(
      id: 'lv3',
      title: '지난 라이브 | 팬레터 100통 읽기',
      scheduledAt: _daysAgo(7),
      emoji: '💌',
      category: '다시보기',
      replayViews: 128000,
    ),
    LiveSession(
      id: 'lv4',
      title: '지난 라이브 | 구독자와 게임 대결',
      scheduledAt: _daysAgo(15),
      emoji: '🎮',
      category: '다시보기',
      replayViews: 96000,
    ),
  ];

  static List<EventItem> events() => [
    EventItem(
      id: 'e1',
      title: '팬레터 이벤트 — 마음을 전해보세요',
      description:
          '가장 감동적인 팬레터 3분을 선정해 라이브에서 직접 소개하고, '
          '한정판 굿즈를 선물로 드립니다.',
      emoji: '💌',
      type: '이벤트',
      startAt: _daysAgo(2),
      endAt: _inDays(12),
      participants: 1284,
      linkLabel: '편지 쓰기',
    ),
    EventItem(
      id: 'e2',
      title: '겨울 한정 굿즈 1차 예약 판매',
      description:
          '머그컵 + 스티커 세트, 후드 담요, 포토카드 4종.\n'
          '1차 예약자에게는 미공개 포토카드 1장을 추가로 드려요.',
      emoji: '🧣',
      type: '굿즈',
      startAt: _daysAgo(1),
      endAt: _inDays(9),
      participants: 892,
      linkLabel: '예약하기',
    ),
    EventItem(
      id: 'e3',
      title: '구독자 25만 돌파 기념 이벤트',
      description:
          '함께해주신 팬분들께 감사한 마음을 담아 '
          '커뮤니티에 축하 메시지를 남겨주신 분들 중 추첨을 통해 선물을 드립니다!',
      emoji: '🎉',
      type: '이벤트',
      startAt: _daysAgo(6),
      endAt: _inDays(4),
      participants: 2317,
      linkLabel: '참여하기',
    ),
    EventItem(
      id: 'e4',
      title: '12월 팬미팅 오프라인 초청',
      description:
          '팬 여러분을 직접 만나고 싶어요. '
          '참여 신청은 커뮤니티 공지를 확인해주세요.',
      emoji: '🎪',
      type: '이벤트',
      startAt: _inDays(10),
      endAt: _inDays(20),
      participants: 412,
      linkLabel: '자세히',
    ),
  ];

  static final FanProfile fanProfile = FanProfile(
    nickname: '봄날팬',
    emoji: '🌷',
    level: 'Lv.5 충성팬',
    points: 4820,
    joinedAt: DateTime(2023, 3, 14),
  );
}
