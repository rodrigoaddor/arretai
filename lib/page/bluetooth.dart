import 'dart:async';
import 'dart:convert';

import 'package:arretai/widget/animated_rotation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'package:arretai/utils.dart' show BluetoothStateHelpers, findCharacteristic;

import 'package:flutter_blue/flutter_blue.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intent/intent.dart' as android_intent;
import 'package:arretai/widget/confirm_dialog.dart';

final bluetooth = FlutterBlue.instance;
final location = Location.instance;

class BluetoothPage extends StatefulWidget {
  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  BluetoothState state;
  bool isScanning = false;
  bool locationDenied = false;

  StreamSubscription stateStream;
  StreamSubscription scanStream;

  @override
  void initState() {
    super.initState();

    stateStream = bluetooth.state.listen((newState) {
      setState(() => state = newState);
      if (state == BluetoothState.on) scan();
    });

    scanStream = bluetooth.isScanning.listen((newState) {
      setState(() => isScanning = newState);
    });

    scan();
  }

  void requestBluetooth() {
    final intent = android_intent.Intent()..setAction('android.bluetooth.adapter.action.REQUEST_ENABLE');
    intent.startActivity();
  }

  Future<void> scan() async {
    if (!await bluetooth.isOn) {
      return requestBluetooth();
    }

    if (!await location.serviceEnabled()) {
      final request = await location.requestService();
      setState(() => locationDenied = !request);
      if (!locationDenied) return scan();
    }

    if (!await bluetooth.isScanning.first) {
      return bluetooth.startScan(timeout: Duration(seconds: 5));
    }
  }

  @override
  void dispose() {
    if (isScanning) bluetooth.stopScan();

    stateStream?.cancel();
    scanStream?.cancel();

    super.dispose();
  }

  void connect(BluetoothDevice device) async {
    final connectedDevices = await bluetooth.connectedDevices;
    await Future.wait(connectedDevices.map((device) => device.disconnect()));

    await device.connect();

    final services = await device.discoverServices();
    final char = findCharacteristic(services, '0000ffe1-0000-1000-8000-00805f9b34fb');
    if (char != null) await char.write(utf8.encode('connected'));
  }

  void disconnect(BluetoothDevice device) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmDialog(
        title: 'Desconectar dispositivo?',
        confirmText: 'Desconectar',
      ),
    );

    if (confirm) await device.disconnect();
  }

  IconData getBluetoothIcon(BluetoothDeviceState state) {
    switch (state) {
      case BluetoothDeviceState.connected:
        return Icons.bluetooth_connected;
      case BluetoothDeviceState.connecting:
        return Icons.bluetooth_searching;
      default:
        return Icons.bluetooth;
    }
  }

  Widget buildNoBluetooth() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_disabled,
              size: 128,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32, bottom: 8),
              child: Text(
                'Bluetooth indisponível',
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Verifique se o Bluetooth está ativado, e se o aplicativo possui permissão para utilizá-lo.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: OutlineButton(
                child: Text('Ligar Bluetooth'),
                onPressed: requestBluetooth,
              ),
            ),
          ],
        ),
      );

  Widget buildNoLocation() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 128,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32, bottom: 8),
              child: Text(
                'Localização indisponível',
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Verifique se a Localização está ativada, e se o aplicativo possui permissão para utilizá-la.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: OutlineButton(
                child: Text('Ligar Localicação'),
                onPressed: scan,
              ),
            ),
          ],
        ),
      );

  Widget buildScanResults(bool isScanning) => StreamBuilder<List<ScanResult>>(
        stream: bluetooth.scanResults,
        builder: (context, snapshot) {
          return !snapshot.hasData || snapshot.data.isEmpty
              ? Column(
                  children: [
                    ListTile(title: Center(child: Text('Nenhum dispositivo encontrado.'))),
                    AnimatedOpacity(
                      opacity: isScanning ? 0 : 1,
                      duration: Duration(milliseconds: 200),
                      child: OutlineButton(
                        child: Text('Procurar novamente'),
                        onPressed: scan,
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.hasData ? snapshot.data.length : 0,
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, index) {
                    final device = snapshot.data[index].device;
                    return StreamBuilder<BluetoothDeviceState>(
                      stream: device.state,
                      builder: (context, snapshot) {
                        final connected = snapshot.hasData && snapshot.data == BluetoothDeviceState.connected;
                        return ListTile(
                          title: Text(
                            device.name != null && device.name.trim().isNotEmpty ? device.name : 'Dispositivo sem nome',
                          ),
                          subtitle: connected ? Text('Conectado') : null,
                          leading: Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              getBluetoothIcon(snapshot.data),
                            ),
                          ),
                          onTap: snapshot.data.isConnected ? () => disconnect(device) : () => connect(device),
                        );
                      },
                    );
                  },
                );
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conectar Dispositivo'),
        backgroundColor: Colors.teal[300],
        flexibleSpace: !isScanning || state != BluetoothState.on
            ? null
            : Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.teal[300],
                    valueColor: AlwaysStoppedAnimation(Colors.teal[700]),
                  ),
                ),
              ),
      ),
      body: state != BluetoothState.on
          ? buildNoBluetooth()
          : locationDenied ? buildNoLocation() : buildScanResults(isScanning),
      floatingActionButton: state != BluetoothState.on
          ? null
          : FloatingActionButton(
              child: AnimatedRotation(
                rotation: isScanning ? 1 : 0,
                duration: Duration(seconds: 1),
                curve: Curves.easeInOutBack,
                child: FaIcon(FontAwesomeIcons.redoAlt),
              ),
              onPressed: scan,
            ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }
}
