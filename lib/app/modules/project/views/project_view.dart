import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/project_controller.dart';

class ProjectView extends GetView<ProjectController> {
  const ProjectView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      appBar: AppBar(
        backgroundColor: const Color(0xFF001b94),
        title: const Text('My Space'),
        centerTitle: true,
        actions: [
          IconButton(
            iconSize: 40,
            onPressed: () {
              controller.pickFile();
            },
            icon: const Icon(
              Icons.folder,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF001b94),
        onPressed: () {
          Get.toNamed("/nomopro")
              ?.then((value) => controller.getSavedProjectList);
        },
        child: const Icon(Icons.play_arrow, size: 40),
      ),
      body: Obx(() => controller.file.isEmpty
          ? const Center(child: Text('No Projects Found'))
          : Container(
              padding: const EdgeInsets.all(10),
              child: GridView.count(
                crossAxisCount: 5,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: List.generate(controller.file.length, (index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.grey, width: 2),
                    ),
                    child: InkWell(
                      onTap: () {
                        controller.onProjectLoaded(controller.file[index].path);
                      },
                      onLongPress: () {
                        controller.onLongPress(controller.file[index].path);
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                image: DecorationImage(
                                  image: FileImage(
                                      controller.createFileFromPath(
                                          controller.file[index].path)),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Text(
                                controller.file[index].path
                                    .split('/')
                                    .last
                                    .replaceAll(".ob", ''),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                          )
                        ],
                      ),
                    ),
                  );
                }),
              ),
            )),
    );
  }
}
