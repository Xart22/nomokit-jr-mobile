import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Container(
                height: Get.height / 3,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/icon/logo.png"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20)
                  .copyWith(top: 10)
                  .copyWith(bottom: 10),
              width: Get.width / 2,
              child: Obx(() => TextField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      errorText: controller.emailError.value == ''
                          ? null
                          : controller.emailError.value,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: controller.emailError.value == ''
                              ? Colors.white
                              : Colors.red,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelText: 'Email',
                    ),
                  )),
            ),
            Container(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
              ).copyWith(bottom: 10),
              width: Get.width / 2,
              child: Obx(() => TextField(
                    controller: controller.passwordController,
                    obscureText: !controller.isShowPassword.value,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      errorText: controller.passwordError.value == ''
                          ? null
                          : controller.passwordError.value,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: controller.passwordError.value == ''
                              ? Colors.grey
                              : Colors.red,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        onPressed: () {
                          controller.isShowPassword.value =
                              !controller.isShowPassword.value;
                        },
                        icon: Icon(
                          controller.isShowPassword.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                  )),
            ),
            Container(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              width: Get.width / 2,
              child: Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.amber[800]),
                    onPressed: controller.submit,
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Text('Login'),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
