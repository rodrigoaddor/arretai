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