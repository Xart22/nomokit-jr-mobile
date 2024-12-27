import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/stetting_controller.dart';

class StettingView extends GetView<StettingController> {
  const StettingView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StettingView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'StettingView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
