import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:nomokitjr/app/data/proejct_categories_model.dart';

import '../../../utils/loading_progress.dart';
import '../controllers/upload_project_controller.dart';

class UploadProjectView extends GetView<UploadProjectController> {
  const UploadProjectView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Project'),
        centerTitle: true,
      ),
      body: Stack(children: [
        Padding(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: Get.width,
                        height: 200,
                        child: Image.file(File(controller.file.value.path
                            .replaceAll("ob", "png"))),
                      ),
                      const Text(
                        "Title",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Obx(() => TextField(
                            controller: controller.titleController,
                            textInputAction: TextInputAction.next,
                            onChanged: (value) =>
                                controller.titleError.value = '',
                            decoration: InputDecoration(
                              errorText: controller.titleError.value != ''
                                  ? controller.titleError.value
                                  : null,
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "Category",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      SizedBox(
                          width: Get.width,
                          child: Obx(
                            () => DropdownSearch<ProjectCategory>(
                              popupProps: const PopupProps.menu(
                                showSearchBox: false,
                                fit: FlexFit.loose,
                              ),
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  errorText:
                                      controller.categoryError.value != ''
                                          ? controller.categoryError.value
                                          : null,
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  errorBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                    ),
                                  ),
                                  hintText: 'Select Category',
                                ),
                              ),
                              items: controller.list,
                              itemAsString: (item) => item.name,
                              onChanged: (value) {
                                controller.categoryError.value = '';
                                controller.selectedCategory.value = value!.id;
                              },
                            ),
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Obx(() => TextField(
                            controller: controller.desc,
                            maxLines: 5,
                            onChanged: (value) =>
                                controller.desError.value = '',
                            decoration: InputDecoration(
                              errorText: controller.desError.value != ''
                                  ? controller.desError.value
                                  : null,
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: Get.width,
                        child: Obx(() => ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              onPressed: controller.submit,
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Upload'),
                            )),
                      ),
                    ]),
              ),
            )),
        Obx(() => controller.isLoading.value
            ? Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: Get.height,
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: LoadingProgressIndicator(
                      value: controller.progress.value,
                      showCancelButton: false,
                    ),
                  ),
                ),
              )
            : Container())
      ]),
    );
  }
}
