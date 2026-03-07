class AppConstants {
  AppConstants._();

  // --- App Info ---
  static const String appName = 'Focus App';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Premium Focus Timer and Productivity App';

  // --- Method Channel ---
  static const String methodChannelName = 'com.example.focus_app/app_blocker';

  // --- SharedPreferences Keys ---
  static const String prefThemeMode = 'theme_mode';
  static const String prefUserId = 'user_id';
  static const String prefUserName = 'user_name';
  static const String prefUserEmail = 'user_email';
  static const String prefUserPhoto = 'user_photo';
  static const String prefTotalFocusTime = 'total_focus_time';
  static const String prefTotalSessions = 'total_sessions';
  static const String prefCurrentStreak = 'current_streak';
  static const String prefBestStreak = 'best_streak';
  static const String prefLastSessionDate = 'last_session_date';
  static const String prefSoundEnabled = 'sound_enabled';
  static const String prefVibrationEnabled = 'vibration_enabled';
  static const String prefNotificationEnabled = 'notification_enabled';

  // --- Timer Defaults ---
  static const int defaultFocusMinutes = 25;
  static const int defaultShortBreakMinutes = 5;
  static const int defaultLongBreakMinutes = 15;
  static const int maxFocusHours = 12;
  static const int maxFocusMinutes = 59;
  static const int timerTickThreshold = 10;

  // --- Leaderboard ---
  static const int leaderboardTopCount = 100;
  static const String leaderboardCollection = 'leaderboard';
  static const String usersCollection = 'users';
  static const String sessionsCollection = 'focus_sessions';

  // --- Study Tube Whitelisted Channels ---
  static const List<Map<String, String>> whitelistedChannels = [
    {
      'name': 'Khan Academy',
      'channelId': 'UC4a-Gbdw7vOaccHmFo40b9g',
      'description': 'Free world-class education for anyone, anywhere.',
    },
    {
      'name': 'CrashCourse',
      'channelId': 'UCX6b17PVsYBQ0ip5gyeme-Q',
      'description': 'Educational courses on science, history, and more.',
    },
    {
      'name': '3Blue1Brown',
      'channelId': 'UCYO_jab_esuFRV4b17AJtAw',
      'description': 'Mathematics with visual and intuitive explanations.',
    },
    {
      'name': 'TED-Ed',
      'channelId': 'UCsooa4yRKGN_zEE8iknghZA',
      'description': 'Lessons worth sharing from educators worldwide.',
    },
    {
      'name': 'Kurzgesagt',
      'channelId': 'UCsXVk37bltHxD1rDPwtNM8Q',
      'description': 'Science videos explaining complex topics simply.',
    },
    {
      'name': 'MIT OpenCourseWare',
      'channelId': 'UCEBb1b_L6zDS3xTUrIALZOw',
      'description': 'Free lecture videos from MIT courses.',
    },
    {
      'name': 'Organic Chemistry Tutor',
      'channelId': 'UCEWpbFLzoYGPfuWUMFPSaoA',
      'description': 'Math and science tutorials for students.',
    },
    {
      'name': 'Professor Leonard',
      'channelId': 'UCoHhuummRZaIVX7bD4t2czg',
      'description': 'Full-length math lectures for college students.',
    },
  ];

  // --- Default Blocked Apps ---
  static const List<String> defaultBlockedPackages = [
    'com.google.android.youtube',
    'com.facebook.katana',
    'com.instagram.android',
    'com.twitter.android',
    'com.zhiliaoapp.musically',
    'com.snapchat.android',
    'com.reddit.frontpage',
    'com.pinterest',
    'com.netflix.mediaclient',
    'com.amazon.avod.thirdpartyclient',
  ];

  // --- Essential Apps (Never Block) ---
  static const List<String> essentialPackages = [
    'com.android.dialer',
    'com.android.contacts',
    'com.google.android.dialer',
    'com.samsung.android.dialer',
    'com.android.mms',
    'com.google.android.apps.messaging',
    'com.samsung.android.messaging',
    'com.whatsapp',
    'com.whatsapp.w4b',
    'com.android.settings',
    'com.android.systemui',
  ];

  // --- Database ---
  static const String databaseName = 'focus_app.db';
  static const int databaseVersion = 1;

  // --- Animation Durations ---
  static const int splashDurationMs = 3000;
  static const int shortAnimationMs = 200;
  static const int mediumAnimationMs = 400;
  static const int longAnimationMs = 600;
  static const int pageTransitionMs = 300;
}
