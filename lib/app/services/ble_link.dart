import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart'
    show Permission, openAppSettings;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class _BleSession {
  BluetoothDevice? device;
  final Map<String, ScanResult> discovered = {};
  List<BluetoothService> services = [];
  StreamSubscription<List<ScanResult>>? scanSub;
  final Map<String, StreamSubscription<List<int>>> notifySubs = {};
}

class BleLinkService {
  final Map<String, _BleSession> _sessions = {};

  Future<void> handleSend(
    String socketId,
    String type,
    String msg,
    InAppWebViewController ctr,
  ) async {
    debugPrint('[FBP] handleSend entered type=$type msg=$msg');
    if (type != 'BLE') return;

    final session = _sessions.putIfAbsent(socketId, () => _BleSession());
    Map<String, dynamic> req;
    try {
      req = jsonDecode(msg) as Map<String, dynamic>;
      debugPrint('[FBP] decoded method=${req['method']}');
    } catch (e) {
      debugPrint('[FBP] json decode error: $e');
      return;
    }

    final method = req['method'] as String? ?? '';
    final params = (req['params'] as Map?)?.cast<String, dynamic>() ?? {};
    final id = req['id'];

    try {
      debugPrint('[FBP] method=$method type=$type socket=$socketId');
      switch (method) {
        case 'discover':
          await _discover(session, params, socketId, ctr);
          _sendResponse(socketId, ctr, id, null);
          break;
        case 'connect':
          await _connect(session, params);
          _sendResponse(socketId, ctr, id, null);
          break;
        case 'read':
          final result = await _read(session, params);
          _sendResponse(socketId, ctr, id, result);
          break;
        case 'write':
          await _write(session, params);
          _sendResponse(socketId, ctr, id, null);
          break;
        case 'startNotifications':
          await _startNotifications(session, params, socketId, ctr);
          _sendResponse(socketId, ctr, id, null);
          break;
        default:
          _sendResponse(socketId, ctr, id, null);
      }
    } catch (e) {
      debugPrint('[FBP] error: $e');
      _sendError(socketId, ctr, id, {'code': -1, 'message': e.toString()});
    }
  }

  Future<void> handleClose(
    String socketId,
    String type,
    InAppWebViewController ctr,
  ) async {
    if (type != 'BLE') return;
    final session = _sessions.remove(socketId);
    if (session == null) return;
    await session.scanSub?.cancel();
    for (final sub in session.notifySubs.values) {
      await sub.cancel();
    }
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
    try {
      await session.device?.disconnect();
    } catch (_) {}
  }

  Future<bool> _ensurePermissions() async {
    final scan = await Permission.bluetoothScan.status;
    final connect = await Permission.bluetoothConnect.status;
    debugPrint('[FBP] perm scan=$scan connect=$connect');
    if (scan.isGranted && connect.isGranted) return true;
    final result = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
    debugPrint('[FBP] perm result=$result');
    final ok = result.values.every((s) => s.isGranted);
    if (!ok && (scan.isPermanentlyDenied || connect.isPermanentlyDenied)) {
      await openAppSettings();
    }
    return ok;
  }

  Future<void> _discover(
    _BleSession session,
    Map<String, dynamic> params,
    String socketId,
    InAppWebViewController ctr,
  ) async {
    if (!await _ensurePermissions()) {
      throw Exception('Bluetooth permissions not granted');
    }

    final services = <Guid>[];
    final filters = (params['filters'] as List?) ?? const [];
    for (final filter in filters) {
      final list = (filter as Map)['services'] as List? ?? const [];
      for (final uuid in list) {
        services.add(Guid(uuid as String));
      }
    }

    await FlutterBluePlus.stopScan();
    await session.scanSub?.cancel();
    session.discovered.clear();

    session.scanSub = FlutterBluePlus.scanResults.listen((results) {
      debugPrint('[FBP] scan results len=${results.length}');
      for (final r in results) {
        final id = r.device.remoteId.str;
        if (session.discovered.containsKey(id)) continue;
        final name = (r.device.platformName.isNotEmpty
                ? r.device.platformName
                : r.advertisementData.advName)
            .trim();
        debugPrint('[FBP] scan result: $id $name rssi=${r.rssi}');
        if (!_isWeDo(name)) continue;
        session.discovered[id] = r;
        _sendNotification(socketId, ctr, 'didDiscoverPeripheral', {
          'peripheralId': id,
          'name': name,
          'rssi': r.rssi,
        });
      }
    });

    // ponytail: withServices filter can hide WeDo hubs that advertise only
    // LEGO service-data (0xfe07) instead of the GATT UUID. Scan unfiltered and
    // match by name. Re-add withServices only if a hub proves to advertise it.
    debugPrint('[FBP] starting scan...');
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
    );
    debugPrint('[FBP] startScan returned');
  }

  bool _isWeDo(String name) {
    final lower = name.toLowerCase();
    return lower.contains('wedo') ||
        lower.contains('lego') ||
        lower.contains('hub');
  }

  Future<void> _connect(_BleSession session, Map<String, dynamic> params) async {
    final peripheralId = params['peripheralId'] as String? ?? '';
    final result = session.discovered[peripheralId];
    if (result == null) {
      throw Exception('Peripheral not found: $peripheralId');
    }
    await FlutterBluePlus.stopScan();
    await result.device.connect();
    session.device = result.device;
    session.services = await result.device.discoverServices();
  }

  Future<String> _read(_BleSession session, Map<String, dynamic> params) async {
    final ch = _findCharacteristic(session, params);
    try {
      final bytes = await ch.read();
      return base64Encode(bytes);
    } catch (e) {
      // ATTACHED_IO is notify-only on WeDo 2.0 (READ not supported).
      // Return empty string instead of throwing: BLE.read() treats any
      // JSON-RPC error as a disconnect, which would kill the connection.
      debugPrint('[FBP] read not supported, returning empty: $e');
      return '';
    }
  }

  Future<void> _write(_BleSession session, Map<String, dynamic> params) async {
    final ch = _findCharacteristic(session, params);
    final bytes = base64Decode((params['message'] as String?) ?? '');
    final withResponse = params['withResponse'] == true;
    await ch.write(bytes, withoutResponse: !withResponse);
  }

  Future<void> _startNotifications(
    _BleSession session,
    Map<String, dynamic> params,
    String socketId,
    InAppWebViewController ctr,
  ) async {
    final serviceUuid = Guid(params['serviceId'] as String);
    final characteristicUuid = Guid(params['characteristicId'] as String);
    final ch = _findCharacteristic(session, params);
    await ch.setNotifyValue(true);

    final key = '${serviceUuid.str}/${characteristicUuid.str}';
    await session.notifySubs[key]?.cancel();
    session.notifySubs[key] = ch.onValueReceived.listen((bytes) {
      _sendNotification(
        socketId,
        ctr,
        'characteristicDidChange',
        {'message': base64Encode(bytes)},
      );
    });
  }

  BluetoothCharacteristic _findCharacteristic(
    _BleSession session,
    Map<String, dynamic> params,
  ) {
    final serviceUuid = Guid(params['serviceId'] as String);
    final characteristicUuid = Guid(params['characteristicId'] as String);
    for (final service in session.services) {
      if (service.serviceUuid == serviceUuid) {
        for (final ch in service.characteristics) {
          if (ch.characteristicUuid == characteristicUuid) return ch;
        }
      }
    }
    throw Exception('Characteristic not found: $characteristicUuid');
  }

  void _sendResponse(
    String socketId,
    InAppWebViewController ctr,
    dynamic id,
    dynamic result,
  ) {
    _post(
      ctr,
      socketId,
      {'jsonrpc': '2.0', 'id': id, 'result': result},
    );
  }

  void _sendError(
    String socketId,
    InAppWebViewController ctr,
    dynamic id,
    Map<String, dynamic> error,
  ) {
    _post(
      ctr,
      socketId,
      {'jsonrpc': '2.0', 'id': id, 'error': error},
    );
  }

  void _sendNotification(
    String socketId,
    InAppWebViewController ctr,
    String method,
    Map<String, dynamic> params,
  ) {
    _post(
      ctr,
      socketId,
      {'jsonrpc': '2.0', 'method': method, 'params': params},
    );
  }

  void _post(
    InAppWebViewController ctr,
    String socketId,
    Map<String, dynamic> payload,
  ) {
    final envelope = jsonEncode({
      'nomoLink': true,
      'id': socketId,
      'response': jsonEncode(payload),
    });
    ctr.postWebMessage(
      message: WebMessage(data: envelope),
      targetOrigin: WebUri('*'),
    );
  }
}
