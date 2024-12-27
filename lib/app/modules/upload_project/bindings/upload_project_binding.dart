import 'package:get/get.dart';

import '../controllers/upload_project_controller.dart';

class UploadProjectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UploadProjectController>(
      () => UploadProjectController(),
    );
  }
}
