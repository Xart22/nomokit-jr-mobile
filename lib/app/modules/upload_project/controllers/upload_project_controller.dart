import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:nomokitjr/app/data/proejct_categories_model.dart';
import 'package:nomokitjr/app/services/api_service.dart';
import 'package:share_plus/share_plus.dart';

class UploadProjectController extends GetxController {
  var file = XFile(Get.arguments).obs;
  TextEditingController titleController = TextEditingController();
  TextEditingController desc = TextEditingController();
  var isLoading = false.obs;

  var selectedCategory = 0.obs;
  var titleError = ''.obs;
  var desError = ''.obs;
  var categoryError = ''.obs;
  var list = <ProjectCategory>[].obs;
  var progress = 0.0.obs;

  bool validate() {
    if (titleController.text.isEmpty) {
      titleError.value = 'Title Cannot be empty';
      return false;
    } else if (selectedCategory.value == 0) {
      categoryError.value = "Please Select Category";
      return false;
    } else if (desc.text.isEmpty) {
      desError.value = "Description Cannot bet empty";
      return false;
    } else {
      return true;
    }
  }

  void submit() {
    isLoading.value = true;
    bool valid = validate();
    if (valid) {
      ApiService.uploadProject({
        "title": titleController.text,
        "desc": desc.text,
        "categories": selectedCategory.value
      }, XFile(file.value.path.replaceAll('ob', 'png')), file.value)
          .then((value) {
        if (value == 'success') {
          Get.back();
          Fluttertoast.showToast(
            msg: 'Upload Project Success',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 14.0,
          );
        }
      });
    }
    isLoading.value = false;
  }

  void getCategories() async {
    await ApiService.getProjectCategories()
        .then((value) => list.value = value!);
  }

  @override
  void onInit() {
    getCategories();
    titleController.text = file.value.name.replaceAll(".ob", "");
    super.onInit();
  }
}
