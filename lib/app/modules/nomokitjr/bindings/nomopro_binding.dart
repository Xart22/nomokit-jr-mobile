import 'package:get/get.dart';

import '../controllers/nomopro_controller.dart';

class NomoproBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NomoproController>(
      () => NomoproController(),
    );
  }
}
