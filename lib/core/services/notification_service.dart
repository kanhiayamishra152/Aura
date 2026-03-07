// lib/core/services/notification_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  NotificationService._internal();

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Notification Channel IDs
  static const String timerChannelId = 'focus_timer_channel';
  static const String timerChannelName = 'Focus Timer';
  static const String timerChannelDesc = 'Notifications for focus timer events';

  static const String alarmChannelId = 'alarm_channel';
  static const String alarmChannelName = 'Alarms';
  static const String alarmChannelDesc = 'Notifications for alarm events';

  static const String focusModeChannelId = 'focus_mode_channel';
  static const String focusModeChannelName = 'Focus Mode';
  static const String focusModeChannelDesc =
      'Notifications for focus mode status';

  static const String generalChannelId = 'general_channel';
  static const String generalChannelName = 'General';
  static const String generalChannelDesc = 'General app notifications';

  // Notification IDs
  static const int timerCompleteNotifId = 1001;
  static const int timerRunningNotifId = 1002;
  static const int alarmNotifId = 2001;
  static const int focusModeActiveNotifId = 3001;
  static const int focusModeEndNotifId = 3002;
  static const int generalNotifId = 4001;
  static const int rankUpNotifId = 5001;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      tz_data.initializeTimeZones();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
      );

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      await _createNotificationChannels();

      _isInitialized = true;
      debugPrint('NotificationService: Initialized successfully.');
    } catch (e) {
      debugPrint('NotificationService: Error during initialization - $e');
      _isInitialized = false;
    }
  }

  Future<void> _createNotificationChannels() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) {
      return;
    }

    const List<AndroidNotificationChannel> channels =
        <AndroidNotificationChannel>[
      AndroidNotificationChannel(
        timerChannelId,
        timerChannelName,
        description: timerChannelDesc,
        importance: Importance.high,
        playSound: false,
        enableVibration: true,
      ),
      AndroidNotificationChannel(
        alarmChannelId,
        alarmChannelName,
        description: alarmChannelDesc,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
      AndroidNotificationChannel(
        focusModeChannelId,
        focusModeChannelName,
        description: focusModeChannelDesc,
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
      ),
      AndroidNotificationChannel(
        generalChannelId,
        generalChannelName,
        description: generalChannelDesc,
        importance: Importance.defaultImportance,
        playSound: false,
        enableVibration: true,
      ),
    ];

    for (final AndroidNotificationChannel channel in channels) {
      await androidPlugin.createNotificationChannel(channel);
    }

    debugPrint('NotificationService: Notification channels created.');
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint(
      'NotificationService: Notification tapped - ID: ${response.id}, '
      'Payload: ${response.payload}',
    );
  }

  // -------------------------------------------------------
  // Show Instant Notifications
  // -------------------------------------------------------

  Future<void> showTimerComplete() async {
    await _showNotification(
      id: timerCompleteNotifId,
      channelId: timerChannelId,
      channelName: timerChannelName,
      channelDesc: timerChannelDesc,
      title: 'Focus Session Complete',
      body: 'Great work! You have completed your focus session successfully.',
      importance: Importance.high,
      priority: Priority.high,
      payload: 'timer_complete',
    );
  }

  Future<void> showTimerRunning({
    required String remainingTime,
  }) async {
    await _showNotification(
      id: timerRunningNotifId,
      channelId: timerChannelId,
      channelName: timerChannelName,
      channelDesc: timerChannelDesc,
      title: 'Focus Timer Running',
      body: 'Time remaining: $remainingTime',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      payload: 'timer_running',
    );
  }

  Future<void> showAlarmTriggered({
    String alarmLabel = 'Alarm',
  }) async {
    await _showNotification(
      id: alarmNotifId,
      channelId: alarmChannelId,
      channelName: alarmChannelName,
      channelDesc: alarmChannelDesc,
      title: 'Alarm',
      body: alarmLabel,
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      payload: 'alarm_triggered',
    );
  }

  Future<void> showFocusModeActive() async {
    await _showNotification(
      id: focusModeActiveNotifId,
      channelId: focusModeChannelId,
      channelName: focusModeChannelName,
      channelDesc: focusModeChannelDesc,
      title: 'Focus Mode Active',
      body: 'Distracting apps are blocked. Stay focused.',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      payload: 'focus_mode_active',
    );
  }

  Future<void> showFocusModeEnded() async {
    await cancelNotification(focusModeActiveNotifId);

    await _showNotification(
      id: focusModeEndNotifId,
      channelId: focusModeChannelId,
      channelName: focusModeChannelName,
      channelDesc: focusModeChannelDesc,
      title: 'Focus Mode Ended',
      body: 'All apps are now accessible again.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      payload: 'focus_mode_ended',
    );
  }

  Future<void> showRankUp({
    required int newRank,
  }) async {
    await _showNotification(
      id: rankUpNotifId,
      channelId: generalChannelId,
      channelName: generalChannelName,
      channelDesc: generalChannelDesc,
      title: 'Rank Up!',
      body: 'Congratulations! You have reached rank #$newRank on the leaderboard.',
      importance: Importance.high,
      priority: Priority.high,
      payload: 'rank_up',
    );
  }

  Future<void> showGeneral({
    required String title,
    required String body,
    String payload = 'general',
  }) async {
    await _showNotification(
      id: generalNotifId,
      channelId: generalChannelId,
      channelName: generalChannelName,
      channelDesc: generalChannelDesc,
      title: title,
      body: body,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      payload: payload,
    );
  }

  // -------------------------------------------------------
  // Schedule Notification
  // -------------------------------------------------------

  Future<void> scheduleAlarm({
    required int id,
    required String label,
    required DateTime scheduledTime,
  }) async {
    try {
      final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      );

      await _plugin.zonedSchedule(
        id,
        'Alarm',
        label,
        tzScheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            alarmChannelId,
            alarmChannelName,
            channelDescription: alarmChannelDesc,
            importance: Importance.max,
            priority: Priority.max,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
            autoCancel: false,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'alarm_$id',
      );

      debugPrint(
        'NotificationService: Alarm scheduled for $scheduledTime',
      );
    } catch (e) {
      debugPrint('NotificationService: Error scheduling alarm - $e');
    }
  }

  // -------------------------------------------------------
  // Core Notification Builder
  // -------------------------------------------------------

  Future<void> _showNotification({
    required int id,
    required String channelId,
    required String channelName,
    required String channelDesc,
    required String title,
    required String body,
    required Importance importance,
    required Priority priority,
    bool ongoing = false,
    bool autoCancel = true,
    bool fullScreenIntent = false,
    String payload = '',
  }) async {
    if (!_isInitialized) {
      debugPrint('NotificationService: Not initialized. Attempting init.');
      await initialize();
    }

    try {
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: importance,
        priority: priority,
        ongoing: ongoing,
        autoCancel: autoCancel,
        fullScreenIntent: fullScreenIntent,
        category: fullScreenIntent
            ? AndroidNotificationCategory.alarm
            : AndroidNotificationCategory.status,
        visibility: NotificationVisibility.public,
        showWhen: true,
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
      );

      await _plugin.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );

      debugPrint('NotificationService: Notification shown - $title');
    } catch (e) {
      debugPrint('NotificationService: Error showing notification - $e');
    }
  }

  // -------------------------------------------------------
  // Cancel Operations
  // -------------------------------------------------------

  Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
      debugPrint('NotificationService: Cancelled notification $id');
    } catch (e) {
      debugPrint('NotificationService: Error cancelling notification - $e');
    }
  }

  Future<void> cancelTimerNotifications() async {
    await cancelNotification(timerCompleteNotifId);
    await cancelNotification(timerRunningNotifId);
  }

  Future<void> cancelAlarmNotification() async {
    await cancelNotification(alarmNotifId);
  }

  Future<void> cancelFocusModeNotifications() async {
    await cancelNotification(focusModeActiveNotifId);
    await cancelNotification(focusModeEndNotifId);
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _plugin.cancelAll();
      debugPrint('NotificationService: All notifications cancelled.');
    } catch (e) {
      debugPrint(
        'NotificationService: Error cancelling all notifications - $e',
      );
    }
  }

  // -------------------------------------------------------
  // Permission Check
  // -------------------------------------------------------

  Future<bool> requestPermission() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin == null) {
        return false;
      }

      final bool? granted =
          await androidPlugin.requestNotificationsPermission();
      debugPrint(
        'NotificationService: Permission ${granted == true ? "granted" : "denied"}',
      );
      return granted ?? false;
    } catch (e) {
      debugPrint('NotificationService: Error requesting permission - $e');
      return false;
    }
  }

  Future<void> dispose() async {
    await cancelAllNotifications();
    _isInitialized = false;
    debugPrint('NotificationService: Disposed.');
  }
}
