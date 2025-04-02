import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:petpalace/notification/localNotification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:petpalace/theme/app_theme.dart';
import 'package:petpalace/utils/Color.dart';
import 'package:provider/provider.dart';
import 'Database/Fav.dart';
import 'authentication/auth.dart';
import 'authentication/authBloc/authBloc.dart';
import 'firebase_options.dart';
import 'constant/constant.dart';
import 'screens/feature_screens/homeScreen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = publishkey;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAuth.instance.setLanguageCode('en');
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest,
  );
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    LocalNotification().showNotification(
      "channel_id",
      message.notification?.title ?? "Notification",
      message.notification?.body ?? "You have a new message",
    );
  });
  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Initialize Flutter local notifications in the background
    LocalNotification().showNotification(
      'new_message_channel',
      'New Message',
      'You have a new message from the sender.',
    );
  }

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        BlocProvider(create: (context) => Authbloc()),
        ChangeNotifierProvider(create: (_) => FavoriteManager()),
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    ThemeColors.init(context);
    return MaterialApp(
      locale: const Locale('en'),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
    );
  }
}
