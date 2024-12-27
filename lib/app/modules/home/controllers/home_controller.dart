import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:nomokitjr/app/services/api_service.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restart_app/restart_app.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/login_response_model.dart';
import '../../../services/blue_serial.dart';
import '../../../services/usb_serial.dart';

class HomeController extends GetxController {
  final storage = GetStorage();
  late UsbSerialService usbService;
  late BlueSerialService bluetoothService;
  final Uri urlSonatronic = Uri.parse('https://tokopedia.link/yPY3uuba4zb');
  final Uri urlRoboClubShopee =
      Uri.parse('https://shopee.co.id/roboclub_store');
  final Uri urlRoboClub = Uri.parse('https://tokopedia.link/RFOavkWnaAb');
  var title = 'Nomokit'.obs;
  var file = [].obs;
  var userData = User(
          avatar: '',
          city: '',
          collageAddress: '',
          collageName: '',
          email: '',
          id: '',
          name: '',
          phone: '',
          province: '',
          subscriptions: null,
          tglLahir: '',
          trial: null,
          username: '')
      .obs;

  Future<void> checkForUpdate() async {
    await InAppUpdate.checkForUpdate().then((info) {
      info.updateAvailability == UpdateAvailability.updateAvailable
          ? InAppUpdate.performImmediateUpdate()
          : null;
    });
  }

  showBottomSheet() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
              leading: Image.asset(
                'assets/icon/tokped.png',
                width: 100,
                height: 100,
              ),
              title: const Center(child: Text('Robooclub Store')),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  Get.back();
                  openShop(urlRoboClub);
                },
                child: const Text('Open', style: TextStyle(color: Colors.blue)),
              ),
            ),
            ListTile(
              leading: Image.asset(
                'assets/icon/tokped.png',
                width: 100,
                height: 100,
              ),
              title: const Center(
                  child: Text(
                'SONANTRONIC',
              )),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  Get.back();
                  openShop(urlSonatronic);
                },
                child: const Text('Open', style: TextStyle(color: Colors.blue)),
              ),
            ),
            ListTile(
              leading: Image.asset(
                'assets/icon/shopee.png',
                width: 100,
                height: 100,
              ),
              title: const Center(child: Text('Roboclub_Store')),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  Get.back();
                  openShop(urlRoboClubShopee);
                },
                child: const Text('Open', style: TextStyle(color: Colors.blue)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openShop(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  askPermision() async {
    var storageStatus = await Permission.storage.status;
    var cameraStatus = await Permission.camera.status;
    var microphoneStatus = await Permission.microphone.status;
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }
    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }
    if (!microphoneStatus.isGranted) {
      await Permission.microphone.request();
    }

    userData.value = User.fromJson(await storage.read('user'));
    title.value = 'Welcome back ${userData.value.username}';
  }

  getSavedProjectList() async {
    var directory = (await getApplicationDocumentsDirectory()).path;
    Directory savedDir = Directory("$directory/saved");
    if (!savedDir.existsSync()) {
      savedDir.createSync(recursive: true);
    }
    file.value = Directory("$directory/saved").listSync();
  }

  checkToken() async {
    await ApiService.getProfile().then((value) async {
      if (!value) {
        await storage.remove('accestoken');
        Restart.restartApp();
      }
    });
  }

  @override
  void onInit() {
    checkToken();
    super.onInit();
    usbService = Get.find<UsbSerialService>();
    bluetoothService = Get.find<BlueSerialService>();

    askPermision();
    getSavedProjectList();
    //checkForUpdate();
  }
}
