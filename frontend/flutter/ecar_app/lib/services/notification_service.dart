import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// This is a global handler for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if it's not already initialized
  await Firebase.initializeApp();
  
  // Print a message to console for debugging
  debugPrint('Handling a background message: ${message.messageId}');
  debugPrint('Background Message data: ${message.data}');
  debugPrint('Background Message notification: ${message.notification?.title}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() {
    return _instance;
  }
  
  NotificationService._internal();
  
  // FlutterLocalNotificationsPlugin instance for showing local notifications
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  // FirebaseMessaging instance for handling FCM
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  // Secure storage for storing the FCM token
  final _secureStorage = const FlutterSecureStorage();
  
  // Android notification channel
  AndroidNotificationChannel? _channel;
  
  // Method to initialize the notification service
  Future<void> initialize() async {
    // Set the background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Initialize Firebase
    await Firebase.initializeApp();
    
    // Request permission (for iOS)
    await _requestPermission();
    
    // Initialize local notifications
    await _initializeLocalNotifications();
    
    // Set up foreground message handling
    _setupForegroundMessageHandling();
    
    // Set up notification click handling
    _setupNotificationClickHandling();
    
    // Get and save FCM token
    await _getAndSaveToken();
  }
  
  // Request permission for notifications (required for iOS)
  Future<void> _requestPermission() async {
    if (Platform.isIOS) {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      debugPrint('User granted permission: ${settings.authorizationStatus}');
    }
  }
  
  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    // Set up Android notification channel
    _channel = const AndroidNotificationChannel(
      'tn_ecar_high_importance_channel', // id
      'Ecar Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.high,
    );
    
    // Create the Android notification channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel!);
    
    // Initialize settings for iOS and Android
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // Handle iOS notification
        debugPrint('Received iOS notification: $title');
      },
    );
    
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    // Initialize the plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        debugPrint('Notification tapped: ${response.payload}');
        if (response.payload != null) {
          // Navigate to the appropriate screen based on payload
          // This could be handled by a callback passed to this service
        }
      },
    );
  }
  
  // Set up foreground message handling
  void _setupForegroundMessageHandling() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');
      
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      
      // Show a local notification
      if (notification != null && android != null && _channel != null) {
        _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel!.id,
              _channel!.name,
              channelDescription: _channel!.description,
              icon: android.smallIcon,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });
  }
  
  // Set up notification click handling
  void _setupNotificationClickHandling() {
    // Handle notification when app is opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('Initial message: ${message.data}');
        // Handle initial message (e.g., navigate to a specific screen)
      }
    });
    
    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message clicked: ${message.data}');
      // Handle message tap (e.g., navigate to a specific screen)
    });
  }
  
  // Get and save FCM token
  Future<void> _getAndSaveToken() async {
    String? token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');
    
    if (token != null) {
      // Save token to secure storage
      await _secureStorage.write(key: 'fcm_token', value: token);
      
      // Send token to backend
      await _sendTokenToBackend(token);
    }
  }
  
  // Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }
  
  // Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }
  
  // Send FCM token to backend
  Future<void> _sendTokenToBackend(String token) async {
    try {
      // Get auth token from secure storage
      final authToken = await _secureStorage.read(key: 'auth_token');
      if (authToken == null) {
        debugPrint('No auth token found, cannot send FCM token to backend');
        return;
      }
      
      // API endpoint for saving FCM token
      const url = 'https://api.ecar.tn/api/v1/users/fcm_token';
      
      // Send the token to backend
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
        }),
      );
      
      if (response.statusCode == 200) {
        debugPrint('FCM token sent to backend successfully');
      } else {
        debugPrint('Failed to send FCM token to backend: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending FCM token to backend: $e');
    }
  }
} 