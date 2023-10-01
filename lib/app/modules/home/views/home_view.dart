import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: const Color(0xFF4d97ff),
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              InAppWebView(
                initialUrlRequest:
                    URLRequest(url: WebUri("http://localhost:8080/")),
                onConsoleMessage: (ctr, consoleMessage) {
                  print(consoleMessage);
                  if (consoleMessage.message.contains("makeyMakey")) {
                    controller.isLoading.value = false;
                  }
                },
                onPermissionRequest: (controller, request) async {
                  return PermissionResponse(
                      resources: request.resources,
                      action: PermissionResponseAction.GRANT);
                },
                onWebViewCreated: (ctr) async {
                  ctr.addJavaScriptHandler(
                    handlerName: "openConnectionModal",
                    callback: (data) async {},
                  );

                  ctr.addJavaScriptHandler(
                    handlerName: "writeToTransport",
                    callback: (data) async {},
                  );

                  ctr.addJavaScriptHandler(
                    handlerName: "blobToBase64Handler",
                    callback: (data) async {
                      if (data.isNotEmpty) {}
                    },
                  );
                  ctr.addJavaScriptHandler(
                    handlerName: "backToHome",
                    callback: (data) async {
                      Get.offAllNamed("/home");
                    },
                  );
                  ctr.addJavaScriptHandler(
                    handlerName: "loadProject",
                    callback: (data) async {},
                  );
                  ctr.addJavaScriptHandler(
                    handlerName: "saveCanvas",
                    callback: (data) async {},
                  );
                },
                onDownloadStartRequest: (ctr, blopRes) async {
                  var fileJs = await rootBundle
                      .loadString("assets/gui/canvas-downloader.js");
                  await ctr.evaluateJavascript(source: fileJs);
                  var jsContent = await rootBundle
                      .loadString("assets/gui/project-downloader.js");
                  await ctr.evaluateJavascript(
                      source: jsContent.replaceAll(
                          "blobUrlPlaceholder", blopRes.url.toString()));
                },
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  supportZoom: false,
                  initialScale: 3,
                  preferredContentMode: UserPreferredContentMode.MOBILE,
                  useOnDownloadStart: true,
                  allowContentAccess: true,
                  allowFileAccessFromFileURLs: true,
                ),
              ),
              Obx(() => controller.isLoading.value ? Container() : Container()),
            ],
          )),
    );
  }
}
