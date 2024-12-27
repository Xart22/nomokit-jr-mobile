import 'package:get/get.dart';

import '../controllers/stetting_controller.dart';

class StettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StettingController>(
      () => StettingController(),
    );
  }
}
