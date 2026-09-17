import 'dart:collection';

import 'package:flutter/foundation.dart';
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
              initialUserScripts: UnmodifiableListView([
                UserScript(
                  source:
                      "window.__nomoBridgeEager = true; console.log('NOMO_EAGER');",
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                ),
              ]),
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
                debugPrint('[NOMO] onWebViewCreated');

                ctr.addJavaScriptHandler(
                  handlerName: "nomoLinkSend",
                  callback: (data) async {
                    debugPrint('[NOMO] send handler data=$data');
                    if (data.isNotEmpty) {
                      await controller.bleLinkService.handleSend(
                        data[0]['socketId'].toString(),
                        data[0]['type'].toString(),
                        data[0]['msg'].toString(),
                        ctr,
                      );
                    }
                  },
                );

                ctr.addJavaScriptHandler(
                  handlerName: "nomoLinkClose",
                  callback: (data) async {
                    if (data.isNotEmpty) {
                      await controller.bleLinkService.handleClose(
                        '${data[0]['socketId']}',
                        '${data[0]['type']}',
                        ctr,
                      );
                    }
                  },
                );

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
              onLoadStop: (ctr, url) async {
                debugPrint('[NOMO] onLoadStop $url');
                try {
                  var bridge = await rootBundle
                      .loadString("assets/gui/nomo-link-bridge.js");
                  await ctr.evaluateJavascript(source: bridge);
                  debugPrint('[NOMO] bridge injected');
                } catch (e) {
                  debugPrint('[NOMO] bridge inject error: $e');
                }
              },
            ),
            Obx(() =>
                controller.isLoading.value ? const LoadingGui() : Container()),
          ],
        ));
  }
}
