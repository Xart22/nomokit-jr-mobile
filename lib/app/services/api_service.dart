import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:nomokitjr/app/data/proejct_categories_model.dart';
import 'package:nomokitjr/app/modules/upload_project/controllers/upload_project_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart' as dio;
import '../data/login_response_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ApiService {
  static final client = http.Client();
  static final storage = GetStorage();
  static String accestoken = storage.read('accestoken');

  static Future<String?> login(String username, String password) async {
    try {
      final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
      String? token = await firebaseMessaging.getToken();
      final response =
          await client.post(Uri.parse('https://nomo-kit.com/api/login'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: json.encode({
                'appFrom': 'android',
                'email': username,
                'password': password,
                'fcm_token': token,
              }));
      if (response.statusCode == 200) {
        final data = loginResponseModelFromJson(response.body);
        await storage.write('accestoken', data.token);
        await storage.write('user', data.user.toJson());
        return 'success';
        if (data.user.subscriptions == null && data.user.trial == null) {
          Get.snackbar(
            'Failed',
            'You are not subscribed to any plan',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
          );
          return 'failed';
        } else if (data.user.subscriptions != null &&
            data.user.subscriptions?.isActive == 1) {
          await storage.write('user', data.user.toJson());

          return 'success';
        } else if (data.user.trial != null && data.user.trial?.isActive == 1) {

        } else {
          Get.snackbar(
            'Failed',
            'You are not subscribed to any plan',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
          );
          return 'failed';
        }
      } else {
        return 'error';
      }
    } catch (e, s) {
      print(e);
      print(s);
      return 'error';
    }
  }

  static Future<bool> updateFcm(String token) async {
    await getAccesToken();
    try {
      final response = await client
          .post(Uri.parse('https://nomo-kit.com/api/login'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $accestoken',
              },
              body: json.encode({
                'fcm_token': token,
              }))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan');
    }
  }

  static Future<bool> logout() async {
    await getAccesToken();
    try {
      final response =
          await client.post(Uri.parse('https://nomo-kit.com/api/logout'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $accestoken',
              },
              body: json.encode({'app': 'mobile'}));
      if (response.statusCode == 200) {
        await storage.remove('accestoken');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      throw Exception('Terjadi kesalahan');
    }
  }

  static getAccesToken() async {
    accestoken = await storage.read('accestoken');
  }

  static Future<bool> getProfile() async {
    await getAccesToken();
    try {
      final response = await client.get(
        Uri.parse('https://nomo-kit.com/api/user'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accestoken',
        },
      );
      if (response.statusCode == 200) {
        final data = loginResponseModelFromJson(response.body);
        await storage.write('user', data.user.toJson());
        return true;
        if (data.user.subscriptions == null && data.user.trial == null) {
          Get.snackbar(
            'Failed',
            'You are not subscribed to any plan',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
          );
          return false;
        } else if (data.user.subscriptions != null &&
            data.user.subscriptions?.isActive == 1) {

        } else if (data.user.trial != null && data.user.trial?.isActive == 1) {

        } else {
          Get.snackbar(
            'Failed',
            'You are not subscribed to any plan',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
          );
          return false;
        }
      } else {
        return false;
      }
    } catch (e, s) {
      print(e);
      print(s);
      return false;
    }
  }

  static Future<List<ProjectCategory>?> getProjectCategories() async {
    await getAccesToken();
    try {
      final response = await client.get(
        Uri.parse('https://nomo-kit.com/api/get-project-categories'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accestoken',
        },
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = projectCategoriesResponseModelFromJson(response.body);

        return data.categories;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan');
    }
  }

  static Future<String> uploadProject(
      Map<String, dynamic> body, XFile? img, XFile? filePath) async {
    await getAccesToken();
    try {
      var formData = dio.FormData.fromMap({
        "title": body['title'],
        "description": body['desc'],
        "project_category_id": body['categories'],
        "file": await dio.MultipartFile.fromFile(filePath!.path,
            filename: '${body['title']}.ob',
            contentType: MediaType('application/x.openblock.ob', "ob")),
        "image": await dio.MultipartFile.fromFile(img!.path,
            filename: '${body['title']}.png',
            contentType: MediaType('image', 'png'))
      });

      final response =
          await dio.Dio().post("https://nomo-kit.com/api/upload-project",
              options: dio.Options(headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $accestoken',
              }),
              data: formData, onSendProgress: (count, total) {
        Get.find<UploadProjectController>().progress.value = (count / total);
      });

      final responseData = response.data;
      if (responseData['status'] == "succes") {
        return 'success';
      } else {
        return 'failed';
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Tidak ada Koneksi Internet / Internet Tidak Stable',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return 'false';
    }
  }
}
