import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nomokitjr/app/services/api_service.dart';
import 'package:restart_app/restart_app.dart';

import '../../../data/login_response_model.dart';

class ProfileController extends GetxController {
  final storage = GetStorage();
  var userData = User(
          avatar: 'user.png',
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
          username: '',
          trial: null)
      .obs;

  getProfile() async {
    await ApiService.getProfile();
    userData.value = User.fromJson(await storage.read('user'));
  }

  logout() async {
    await ApiService.logout().then((value) => Restart.restartApp());
  }

  @override
  void onInit() {
    getProfile();
    super.onInit();
  }
}
