import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:get/get.dart';

import '../data/message_model.dart';

class BlueSerialService extends GetxService {
  static const _channel =
      MethodChannel('com.instareducation.nomokit.BLUETOOTH_STATE');
  final blueSerial = BluetoothClassic();
  bool bluetoothEnabled = false;
  bool isConnected = false;
  final ScrollController listScrollController = ScrollController();
  var messages = <Message>[].obs;
  var messageBuffer = ''.obs;
  var chat = <Row>[].obs;
  var address = "".obs;
  var name = "".obs;

  Timer? discoverableTimeoutTimer;
  int discoverableTimeoutSecondsLeft = 0;

  StreamSubscription? _dataSubscription;
  StreamSubscription? _discoverySubscription;
  List<Device> discoveredDevices = [];

  Future<List<Device>> startDiscovery() async {
    discoveredDevices.clear();

    // Get paired devices first
    List<Device> pairedDevices = await blueSerial.getPairedDevices();
    discoveredDevices.addAll(pairedDevices);

    // Listen for newly discovered devices
    _discoverySubscription = blueSerial.onDeviceDiscovered().listen((device) {
      if (!discoveredDevices.any((d) => d.address == device.address)) {
        discoveredDevices.add(device);
      }
    });

    // Start scanning
    await blueSerial.startScan();

    return discoveredDevices;
  }

  void stopDiscovery() {
    _discoverySubscription?.cancel();
    blueSerial.stopScan();
  }

  Future<bool> connect(String address, Function(Uint8List)? chatBuilder) async {
    try {
      String sppUUID = "00001101-0000-1000-8000-00805F9B34FB";
      await blueSerial.connect(address, sppUUID);

      if (chatBuilder != null) {
        _dataSubscription = blueSerial.onDeviceDataReceived().listen((data) {
          chatBuilder(data);
        });
      }

      isConnected = true;
      return true;
    } catch (exception) {
      isConnected = false;
      return false;
    }
  }

  Future<bool> write(Uint8List data) {
    return blueSerial.writeBytes(data);
  }

  disconnect() async {
    _dataSubscription?.cancel();
    await blueSerial.disconnect();
    isConnected = false;
  }

  Future<BlueSerialService> init() async {
    bluetoothEnabled =
        await _channel.invokeMethod<bool>('isBluetoothEnabled') ?? false;
    if (!bluetoothEnabled) {
      return this;
    }
    await blueSerial.initPermissions();
    return this;
  }
}
