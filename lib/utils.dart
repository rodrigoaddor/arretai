import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue/flutter_blue.dart';

BluetoothCharacteristic findCharacteristic(List<BluetoothService> services, String uuid) {
  return services
      .expand((service) => service.characteristics)
      .firstWhere((characteristic) => characteristic.uuid.toString() == uuid);
}

extension BluetoothStateHelpers on BluetoothDeviceState {
  String toHumanString() {
    final name = toString().split('.')[1];
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  bool get isConnected => this == BluetoothDeviceState.connected || this == BluetoothDeviceState.connecting;
}

extension WaitForMessage on BluetoothCharacteristic {
  Future<String> waitForMessage([RegExp filter]) async {
    final completer = Completer<String>();
    await setNotifyValue(true);
    value.listen((event) {
      final message = utf8.decode(event);
      if (filter == null || filter.hasMatch(message)) {
        completer.complete(message);
      }
    });
    return completer.future;
  }
}
