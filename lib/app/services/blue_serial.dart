import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/message_model.dart';

class BlueSerialService extends GetxService {
  final blueSerial = FlutterBluetoothSerial.instance;
  BluetoothState bluetoothState = BluetoothState.UNKNOWN;
  BluetoothConnection? connection;
  final ScrollController listScrollController = ScrollController();
  var messages = <Message>[].obs;
  var messageBuffer = ''.obs;
  var chat = <Row>[].obs;
  var address = "".obs;
  var name = "".obs;

  Timer? discoverableTimeoutTimer;
  int discoverableTimeoutSecondsLeft = 0;

  StreamSubscription<BluetoothDiscoveryResult>? startDiscovery(
      Function(BluetoothDiscoveryResult?) callback) {
    return blueSerial.startDiscovery().listen((callback));
  }

  Future<bool> connect(String address, Function(Uint8List)? chatBuilder) async {
    try {
      connection = await BluetoothConnection.toAddress(address);
      if (chatBuilder != null) {
        connection?.input?.listen(chatBuilder);
      }
      return true;
    } catch (exception) {
      return false;
    }
  }

  disconnect() async {
    connection?.close();
    connection = null;
  }

  Future<BlueSerialService> init() async {
    var statusBluetoothScan = await Permission.bluetoothScan.status;
    var statusbluetoothConnect = await Permission.bluetoothConnect.status;
    var statusbluetooth = await Permission.bluetooth.status;
    var statusbluetoothAdvertise = await Permission.bluetoothAdvertise.status;
    if (!statusBluetoothScan.isGranted) {
      await Permission.bluetoothScan.request();
    }
    if (!statusbluetooth.isGranted) {
      await Permission.bluetooth.request();
    }
    if (!statusbluetoothAdvertise.isGranted) {
      await Permission.bluetoothAdvertise.request();
    }
    if (!statusbluetoothConnect.isGranted) {
      await Permission.bluetoothConnect.request();
    }

    blueSerial.state.then((state) {
      bluetoothState = state;
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await blueSerial.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      blueSerial.address.then((add) {
        address.value = add!;
      });
    });

    blueSerial.name.then((nm) {
      name.value = nm!;
    });

    // Listen for futher state changes
    blueSerial.onStateChanged().listen((BluetoothState state) {
      bluetoothState = state;

      // Discoverable mode is disabled when Bluetooth gets disabled
      discoverableTimeoutTimer = null;
      discoverableTimeoutSecondsLeft = 0;
    });

    return this;
  }
}
