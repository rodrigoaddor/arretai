import 'dart:convert';

import 'package:arretai/data/state.dart';
import 'package:arretai/page/bluetooth.dart';
import 'package:arretai/utils.dart';
import 'package:arretai/widget/timer_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

class PersonalizePage extends StatefulWidget {
  @override
  _PersonalizePageState createState() => _PersonalizePageState();
}

class _PersonalizePageState extends State<PersonalizePage> {
  TextEditingController timeController;
  FocusNode timeFocus = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    timeController = TextEditingController(text: context.read<AppState>().time?.toString() ?? '');
  }

  void showPositionDialog(VoidCallback onDone) async {
    final theme = Theme.of(context);
    final texts = theme.textTheme;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          child: AspectRatio(
            aspectRatio: 1.5,
            child: TimerClock(
              duration: Duration(seconds: 3),
              done: Text(
                'Posição armazenada!',
                style: texts.headline4,
                textAlign: TextAlign.center,
              ),
              onDone: onDone,
            ),
          ),
        );
      },
    );
  }

  void sendCorrectPos() {
    showPositionDialog(() async {
      (await bluetooth.connectedDevices).forEach((device) async {
        final services = await device.discoverServices();
        final char = findCharacteristic(services, '0000ffe1-0000-1000-8000-00805f9b34fb');
        if (char != null) await char.write(utf8.encode('gravarcor'));
      });
    });
  }

  void sendAlertPos() async {
    showPositionDialog(() async {
      (await bluetooth.connectedDevices).forEach((device) async {
        final services = await device.discoverServices();
        final char = findCharacteristic(services, '0000ffe1-0000-1000-8000-00805f9b34fb');
        if (char != null) await char.write(utf8.encode('gravaraler'));
      });
    });
  }

  void saveTime() async {
    timeFocus.unfocus();
    final state = context.read<AppState>();
    state.time = int.tryParse(timeController.text) ?? 0;
    (await bluetooth.connectedDevices).forEach((device) async {
      final services = await device.discoverServices();
      final char = findCharacteristic(services, '0000ffe1-0000-1000-8000-00805f9b34fb');
      if (char != null) await char.write(utf8.encode('tempo:${state.time}'));
    });

    final theme = Theme.of(context);
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: AspectRatio(
          aspectRatio: 1.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Tempo Ajustado!',
                style: theme.textTheme.headline4,
              ),
              RaisedButton(
                child: Text('Continuar'),
                onPressed: () => Navigator.pop(context),
                color: Colors.lightGreen[600],
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Personalizar'),
        backgroundColor: Colors.lightGreen[600],
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Inclinação',
                style: theme.textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    height: 64,
                    child: Image.asset('assets/images/straight.png'),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: theme.textTheme.bodyText2.copyWith(fontSize: 15),
                              children: [
                                TextSpan(text: 'Posicione seu '),
                                TextSpan(text: 'Arretai', style: TextStyle(color: Colors.lightGreen[600])),
                                TextSpan(text: ' e permaneça na posição correta.'),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          RaisedButton(
                            child: Text('Gravar Posição Correta'),
                            onPressed: sendCorrectPos,
                            color: Colors.lightGreen[600],
                            textColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Relaxe a postura e permaneça na posição a ser corrigida',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyText2.copyWith(fontSize: 15),
                          ),
                          SizedBox(height: 4),
                          RaisedButton(
                            child: Text('Gravar Posição de Alerta'),
                            onPressed: sendAlertPos,
                            color: Colors.lightGreen[600],
                            textColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 64,
                    child: Image.asset('assets/images/lean.png'),
                  ),
                ],
              ),
              SizedBox(height: 64),
              Text(
                'Tempo',
                style: theme.textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: theme.textTheme.bodyText2.copyWith(fontSize: 15),
                    children: [
                      TextSpan(text: 'Após quantos segundos na posição de alerta seu '),
                      TextSpan(text: 'Arretai', style: TextStyle(color: Colors.lightGreen[600])),
                      TextSpan(text: ' deve vibrar.'),
                    ],
                  ),
                ),
              ),
              Form(
                child: Builder(
                  builder: (context) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: TextFormField(
                          controller: timeController,
                          focusNode: timeFocus,
                          autovalidate: false,
                          validator: (str) =>
                              (int.tryParse(str) == null || int.tryParse(str) <= 0) ? 'Tempo inválido' : null,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.lightGreen[600], width: 2),
                              ),
                              helperText: '',
                              labelText: 'Segundos',
                              labelStyle: TextStyle(
                                color: Colors.lightGreen[600],
                              ),
                              hintText: 'Digite o tempo em segundos',
                              floatingLabelBehavior: FloatingLabelBehavior.always),
                        ),
                      ),
                      RaisedButton(
                        child: Text('Gravar Tempo'),
                        onPressed: () {
                          if (Form.of(context).validate()) {
                            saveTime();
                          }
                        },
                        color: Colors.lightGreen[600],
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
