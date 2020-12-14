import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:arretai/utils.dart';
import 'package:arretai/widget/big_icon_button.dart';
import 'package:arretai/widget/time_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:pedantic/pedantic.dart';

final _bluetooth = FlutterBlue.instance;

enum _Stage { Connect, Calibrate, Adjust, Done }

Map<_Stage, String> stageImage = {
  _Stage.Connect: 'posture-straight.png',
  _Stage.Calibrate: 'posture-straight.png',
  _Stage.Adjust: 'posture-relaxed.png',
};

Map<_Stage, List<TextSpan>> stageMessages = {
  _Stage.Connect: [
    TextSpan(text: 'Conecte o '),
    TextSpan(text: 'Arret', style: TextStyle(color: Colors.green[600])),
    TextSpan(text: 'ai', style: TextStyle(color: Colors.grey[700])),
    TextSpan(text: ' a seu celular.'),
  ],
  _Stage.Calibrate: [
    TextSpan(text: 'Calibre', style: TextStyle(color: Colors.green[600])),
    TextSpan(text: ' seu '),
    TextSpan(text: 'Arret', style: TextStyle(color: Colors.green[600])),
    TextSpan(text: 'ai', style: TextStyle(color: Colors.grey[700])),
    TextSpan(text: ' para sua postura ideal.'),
  ],
  _Stage.Adjust: [
    TextSpan(text: 'Com o '),
    TextSpan(text: 'Arret', style: TextStyle(color: Colors.green[600])),
    TextSpan(text: 'ai', style: TextStyle(color: Colors.grey[700])),
    TextSpan(text: ' posicionado, relaxe a postura e '),
    TextSpan(text: 'ajuste o limite.', style: TextStyle(color: Colors.green[600])),
  ],
  _Stage.Done: [
    TextSpan(text: 'Seu '),
    TextSpan(text: 'Arret', style: TextStyle(color: Colors.green[600])),
    TextSpan(text: 'ai', style: TextStyle(color: Colors.grey[700])),
    TextSpan(text: ' está configurado!'),
  ]
};

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _Stage stage = _Stage.Connect;
  int position = 1;

  Future<BluetoothCharacteristic> getDevice() async {
    final device = (await _bluetooth.connectedDevices).first;
    final services = await device.discoverServices();
    return findCharacteristic(services, '0000ffe1-0000-1000-8000-00805f9b34fb');
  }

  void connect(BuildContext context) async {
    final hasResult = await Navigator.pushNamed(context, '/bluetooth');
    if (hasResult == true || kDebugMode) {
      setState(() => stage = _Stage.Calibrate);
      try {
        final device = await getDevice();
        await device.setNotifyValue(true);
        final posReg = RegExp(r'pos-\d');
        device.value.map(utf8.decode).where(posReg.hasMatch).listen((message) {
          setState(() => position = int.parse(message.split('-')[1]));
        });
      } catch (e) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Nenhum dispositivo conectado!' + (kDebugMode ? '\nContinuando em DEBUG' : '')),
        ));
        if (kReleaseMode) {
          return;
        }
      }
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
    BluetoothCharacteristic device;
    try {
      device = await getDevice();
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

    await Future.any([
      Future.delayed(
        Duration(seconds: 5),
      ),
      if (device != null) device.waitForMessage(RegExp('ok'))
    ]);

    Navigator.pop(dialogContext);

    setState(() => stage = _Stage.Adjust);
  }

  void adjust(BuildContext context) async {
    BluetoothCharacteristic device;
    try {
      device = await getDevice();
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

    await Future.any([
      Future.delayed(
        Duration(seconds: 5),
      ),
      if (device != null) device.waitForMessage(RegExp('ok'))
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
        var message = 'tempo:$time';
        if (time < 10) {
          message = 'd$message';
        } else if (time > 99) {
          message = 'c$message';
        }
        await device.write(utf8.encode(message));
      } catch (e) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Nenhum dispositivo conectado!' + (kDebugMode ? '\nTempo: $time' : '')),
        ));
      }
    }

    setState(() => stage = _Stage.Done);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Arretai'),
      ),
      body: Builder(
        builder: (context) => Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64),
              child: SizedBox(
                height: 48,
                child: RichText(
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  text: TextSpan(
                    style: theme.textTheme.headline6,
                    children: stageMessages[stage],
                  ),
                ),
              ),
            ),
            ClipRect(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 72, vertical: 4),
                child: Stack(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: stage != _Stage.Done
                          ? Image.asset(
                              'assets/images/${stageImage[stage]}',
                            )
                          : Image.asset('assets/images/postures/pos-$position.png'),
                    ),
                    if (stage == _Stage.Connect)
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Container(
                            color: Colors.black.withOpacity(0),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: SizedBox.shrink()),
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 56,
                    child: RaisedButton(
                      child: Text('Calibrar'),
                      onPressed: stage.index > 0 ? () => calibrate(context) : null,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox.shrink(),
                ),
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 56,
                    child: RaisedButton(
                      child: Text(
                        'Ajustar Limite',
                        textAlign: TextAlign.center,
                      ),
                      onPressed: stage.index > 1 ? () => adjust(context) : null,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                Expanded(child: SizedBox.shrink()),
              ],
            ),
            SizedBox(
              height: 56,
              child: RaisedButton(
                child: Text('Ajustar Tempo'),
                onPressed: stage == _Stage.Connect ? null : () => setTime(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            BigIconButton(
                icon: Icon(Icons.bluetooth),
                label: Text('Conectar'),
                onPressed: () => connect(context),
                color: Colors.blueAccent[200],
                textColor: Colors.white,
                size: 22,
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                borderRadius: BorderRadius.circular(12)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: SizedBox.expand(
          child: DecoratedBox(
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 4),
                Text('Ajuda',
                    style: theme.textTheme.button.copyWith(color: Colors.red[700], fontWeight: FontWeight.w700)),
                Icon(
                  Icons.help_outline,
                  color: Colors.grey[800],
                ),
              ],
            ),
          ),
        ),
        onPressed: () => Navigator.pushNamed(context, '/help'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
    );
  }
}
