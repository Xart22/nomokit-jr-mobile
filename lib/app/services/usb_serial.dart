import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

class UsbSerialService extends GetxService {
  static const _channel =
      MethodChannel('com.instareducation.nomokit.USB_PERMISSION');
  UsbPort? connectedPort;
  var ports = <Widget>[].obs;
  var serialData = <Widget>[].obs;

  StreamSubscription<String>? subscription;
  Transaction<String>? transaction;

  Future<bool> requestPermission() async {
    return await _channel.invokeMethod('askUsbPermission');
  }

  Future<bool> connect(
      UsbDevice? device, int baudRate, Function(String)? callback) async {
    serialData.clear();

    if (subscription != null) {
      subscription!.cancel();
      subscription = null;
    }

    if (transaction != null) {
      transaction!.dispose();
      transaction = null;
    }

    if (connectedPort != null) {
      connectedPort!.close();
      connectedPort = null;
    }

    if (device == null) {
      device = null;
      return true;
    }

    connectedPort = await device.create();
    if (await (connectedPort!.open()) != true) {
      return false;
    }

    await connectedPort!.setDTR(true);
    await connectedPort!.setRTS(true);
    await connectedPort!.setPortParameters(
        baudRate, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    transaction = Transaction.stringTerminated(
        connectedPort!.inputStream as Stream<Uint8List>,
        Uint8List.fromList([13, 10]));

    subscription = transaction!.stream.listen((callback));

    return true;
  }

  getPorts() {
    return UsbSerial.listDevices();
  }

  Future<UsbSerialService> init() async {
    await requestPermission();
    return this;
  }

  disconnect() async {
    if (connectedPort != null) {
      await connectedPort!.close();
      connectedPort = null;
    }
    if (subscription != null) {
      subscription!.cancel();
      subscription = null;
    }
    if (transaction != null) {
      transaction!.dispose();
      transaction = null;
    }
  }
}
