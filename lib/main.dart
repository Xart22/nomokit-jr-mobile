import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

InAppLocalhostServer localhostServer =
    InAppLocalhostServer(documentRoot: 'assets/gui');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  await GetStorage.init();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await localhostServer.start();
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  var token = await GetStorage().read('accestoken');

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Nomokit Jr",
      initialRoute: token == null ? AppPages.INITIAL : '/home',
      getPages: AppPages.routes,
    ),
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // print("Handling a background message: ${message.messageId}");
  // print("Handling a background message: ${message.notification!.title}");
}
