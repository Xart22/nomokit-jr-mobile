import 'package:get/get.dart';

import '../../../services/blue_serial.dart';
import '../../../services/usb_serial.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut(() => UsbSerialService());
    Get.lazyPut(() => BlueSerialService());
  }
}
