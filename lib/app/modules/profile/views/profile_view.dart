import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
        ),
        body: Stack(children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/img/playground.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: Get.width / 1.2,
              height: Get.height / 1.2,
              child: Card(
                  color: Colors.white.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.grey, width: 2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Obx(() => controller.userData.value.avatar.isEmpty
                                ? Container()
                                : Container(
                                    margin: const EdgeInsets.all(20),
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                            "https://nomo-kit.com/storage/avatar/${controller.userData.value.avatar}"),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  )),
                            Obx(() => Text(controller.userData.value.username)),
                            const SizedBox(
                              height: 10,
                            ),
                            Obx(() => Text(controller.userData.value.email)),
                            const SizedBox(
                              height: 10,
                            ),
                            Obx(() =>
                                controller.userData.value.subscriptions == null
                                    ? Container()
                                    : const Text('Subscription End Date :')),
                            Obx(() => Text(
                                  controller.userData.value.subscriptions ==
                                          null
                                      ? ''
                                      : controller
                                          .userData.value.subscriptions!.endDate
                                          .toIso8601String()
                                          .substring(0, 10),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            Obx(() => controller.userData.value.trial == null
                                ? Container()
                                : const Text('Trial End Date :')),
                            Obx(() => Text(
                                  controller.userData.value.trial == null
                                      ? ''
                                      : controller.userData.value.trial!.endDate
                                          .toIso8601String()
                                          .substring(0, 10),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                controller.logout();
                              },
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Obx(() => ListTile(
                                  title: const Text('Name'),
                                  subtitle:
                                      Text(controller.userData.value.name),
                                )),
                            const Divider(
                              height: 2,
                              thickness: 3,
                            ),
                            Obx(() => ListTile(
                                  title: const Text('Phone'),
                                  subtitle:
                                      Text(controller.userData.value.phone),
                                )),
                            const Divider(
                              height: 2,
                              thickness: 3,
                            ),
                            Obx(() => ListTile(
                                  title: const Text('Collage'),
                                  subtitle: Text(
                                      controller.userData.value.collageName),
                                )),
                            const Divider(
                              height: 2,
                              thickness: 3,
                            ),
                            Obx(() => ListTile(
                                  title: const Text('City'),
                                  subtitle:
                                      Text(controller.userData.value.city),
                                )),
                          ],
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        ]));
  }
}
