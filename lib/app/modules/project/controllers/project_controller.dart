import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class ProjectController extends GetxController {
  var file = <FileSystemEntity>[].obs;
  var filePicker = ''.obs;

  askPermision() async {
    await Permission.storage.request();
  }

  getSavedProjectList() async {
    var directory = (await getApplicationDocumentsDirectory()).path;
    Directory savedDir = Directory("$directory/saved");
    if (!savedDir.existsSync()) {
      savedDir.createSync(recursive: true);
    }
    file.value = Directory("$directory/saved").listSync();
    file.value = file.where((p0) => p0.path.contains('.ob')).toList();
  }

  onLongPress(String path) {
    Get.defaultDialog(
      title: '',
      titlePadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.all(0),
      content: SizedBox(
          width: 400,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  IconButton(
                    iconSize: 30,
                    onPressed: () {
                      Get.back();
                      Get.toNamed('upload-project', arguments: path);
                    },
                    icon: const Icon(
                      Icons.upload,
                      color: Colors.black,
                    ),
                  ),
                  const Text('Upload')
                ],
              ),
              Column(
                children: [
                  IconButton(
                    iconSize: 30,
                    onPressed: () => onShareXFileFromAssets(Get.context!, path),
                    icon: const Icon(
                      Icons.share,
                      color: Colors.blue,
                    ),
                  ),
                  const Text('Share')
                ],
              ),
              Column(
                children: [
                  IconButton(
                    iconSize: 30,
                    onPressed: () {
                      deleteModal(path);
                    },
                    icon: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
                  ),
                  const Text('Delete')
                ],
              ),
            ],
          )),
    );
  }

  deleteModal(String path) {
    Get.defaultDialog(
      title: 'Delete Project',
      middleText: 'Are you sure want to delete this project?',
      textConfirm: 'Yes',
      textCancel: 'No',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await deleteProject(path);
        Get.back();
        Get.back();
      },
      onCancel: () {},
    );
  }

  deleteProject(String path) {
    File file = File(path);
    file.deleteSync();
    File image = File(path.replaceAll('.ob', '.png'));
    image.deleteSync();
    getSavedProjectList();
  }

  createFileFromPath(String path) {
    File file = File(path.replaceAll('.ob', '.png'));

    return file;
  }

  onProjectLoaded(String path) async {
    File file = File(path);
    Uint8List bytes = await file.readAsBytes();
    String base64 = base64Encode(bytes);

    Get.offAndToNamed('/nomopro',
        arguments: [file.path.split('/').last, base64]);
  }

  pickFile() async {
    await FilePicker.platform.pickFiles().then((value) {
      if (value != null) {
        onProjectLoaded(value.files.first.path.toString());
      }
    });
  }

  onShareXFileFromAssets(BuildContext context, String path) async {
    final box = context.findRenderObject() as RenderBox?;

    XFile file = XFile(path);

    await Share.shareXFiles(
      [file],
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );

    Get.back();
  }

  @override
  void onInit() {
    super.onInit();

    askPermision();
    getSavedProjectList();
  }
}
