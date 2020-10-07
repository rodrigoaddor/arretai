import 'dart:async';
import 'dart:convert';

import 'package:arretai/utils.dart';
import 'package:arretai/widget/big_icon_button.dart';
import 'package:arretai/widget/time_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:pedantic/pedantic.dart';

final _bluetooth = FlutterBlue.instance;

enum _Stage { Connect, Calibrate, Adjust }

Map<_Stage, String> stageImage = {
  _Stage.Connect: 'posture-disabled.png',
  _Stage.Calibrate: 'posture-straight.png',
  _Stage.Adjust: 'posture-relaxed.png',
};

class NewHomePage extends StatefulWidget {
  @override
  _NewHomePageState createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  _Stage stage = _Stage.Connect;

  Future<BluetoothCharacteristic> getDevice() async {
    final device = (await _bluetooth.connectedDevices).first;
    final services = await device.discoverServices();
    return findCharacteristic(services, '0000ffe1-0000-1000-8000-00805f9b34fb');
  }

  void connect() async {
    final hasResult = await Navigator.pushNamed(context, '/bluetooth');
    if (hasResult == true || true) {
      setState(() => stage = _Stage.Calibrate);
    }
  }

  Future<BuildContext> showLoadingDialog(Widget child) async {
    var dialogContext = Completer<BuildContext>();

    unawaited(showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        if (!dialogContext.isCompleted) {
          dialogContext.complete(context);
        }

        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            child: AspectRatio(
              aspectRatio: 1.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox.shrink(),
                  CircularProgressIndicator(),
                  child,
                ],
              ),
            ),
          ),
        );
      },
    ));

    return dialogContext.future;
  }

  void calibrate(BuildContext context) async {
    try {
      final device = await getDevice();
      await device.write(utf8.encode('gravarcor'));
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Nenhum dispositivo conectado!' + (kDebugMode ? '\nContinuando em DEBUG' : '')),
      ));
      if (kReleaseMode) {
        return;
      }
    }

    final dialogContext = await showLoadingDialog(Text('Calibrando...'));

    // TODO: receive done from device
    await Future.any([
      Future.delayed(
        Duration(seconds: 5),
      ),
    ]);

    Navigator.pop(dialogContext);

    setState(() => stage = _Stage.Adjust);
  }

  void adjust(BuildContext context) async {
    try {
      final device = await getDevice();
      await device.write(utf8.encode('gravaraler'));
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Nenhum dispositivo conectado!' + (kDebugMode ? '\nContinuando em DEBUG' : '')),
      ));
      if (kReleaseMode) {
        return;
      }
    }

    final dialogContext = await showLoadingDialog(Text('Ajustando Posição...'));

    // TODO: receive done from device
    await Future.any([
      Future.delayed(
        Duration(seconds: 5),
      ),
    ]);

    Navigator.pop(dialogContext);

    setTime(context);
  }

  void setTime(BuildContext context) async {
    final time = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) => TimeDialog(),
    );

    if (time != null) {
      try {
        final device = await getDevice();
        await device.write(utf8.encode('tempo:$time'));
      } catch (e) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Nenhum dispositivo conectado!' + (kDebugMode ? '\nTempo: $time' : '')),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arretai'),
      ),
      body: Builder(
        builder: (context) => Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 72),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Image.asset('assets/images/${stageImage[stage]}'),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: SizedBox.shrink()),
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 48,
                    child: RaisedButton(
                      child: Text('Calibrar'),
                      onPressed: stage.index > 0 ? () => calibrate(context) : null,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox.shrink(),
                ),
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 48,
                    child: RaisedButton(
                      child: Text(
                        'Ajustar Limite',
                        textAlign: TextAlign.center,
                      ),
                      onPressed: stage.index > 1 ? () => adjust(context) : null,
                    ),
                  ),
                ),
                Expanded(child: SizedBox.shrink()),
              ],
            ),
            BigIconButton(
              icon: Icon(Icons.bluetooth),
              label: Text('Conectar'),
              onPressed: connect,
              color: Colors.blueAccent[200],
              textColor: Colors.white,
              size: 18,
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 4),
            Text('Ajuda'),
            Icon(Icons.help_outline),
          ],
        ),
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
    );
  }
}
