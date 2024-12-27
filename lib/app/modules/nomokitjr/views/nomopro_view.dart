import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:get/get.dart';
import 'package:nomokitjr/app/modules/loading_gui.dart';

import '../controllers/nomopro_controller.dart';

class NomoproView extends GetView<NomoproController> {
  const NomoproView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF001b94),
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest:
                  URLRequest(url: WebUri("http://localhost:8080/")),
              onConsoleMessage: (ctr, consoleMessage) {
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
                controller.webViewController = ctr;

                ctr.addJavaScriptHandler(
                  handlerName: "openConnectionModal",
                  callback: (data) async {
                    controller.showConnectionModal();
                  },
                );

                ctr.addJavaScriptHandler(
                  handlerName: "writeToTransport",
                  callback: (data) async {
                    Uint8List comand = Uint8List.fromList(data[0].cast<int>());
                    controller.writeToTransport(comand);
                  },
                );

                ctr.addJavaScriptHandler(
                  handlerName: "blobToBase64Handler",
                  callback: (data) async {
                    if (data.isNotEmpty) {
                      final String receivedFileInBase64 = data[0];
                      controller.showModalTitleProjcet(receivedFileInBase64);
                    }
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
                  callback: (data) async {
                    return controller.projectBlop;
                  },
                );
                ctr.addJavaScriptHandler(
                  handlerName: "saveCanvas",
                  callback: (data) async {
                    controller.imageBlop = data;
                  },
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
            Obx(() =>
                controller.isLoading.value ? const LoadingGui() : Container()),
          ],
        ));
  }
}
