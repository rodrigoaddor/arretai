import 'package:arretai/data/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

class PersonalizePage extends StatefulWidget {
  @override
  _PersonalizePageState createState() => _PersonalizePageState();
}

class _PersonalizePageState extends State<PersonalizePage> {
  TextEditingController timeController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    timeController = TextEditingController(text: context.read<AppState>().time.toString());
  }

  void saveTime() {
    context.read<AppState>().time = int.tryParse(timeController.text ?? ' ');
    print('Saved ${timeController.text}');
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
            children: [
              Column(
                children: [
                  Text(
                    'Inclinação',
                    style: theme.textTheme.subtitle1,
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: theme.textTheme.bodyText2,
                        children: [
                          TextSpan(text: 'Posicione seu '),
                          TextSpan(text: 'Arretai', style: TextStyle(color: Colors.lightGreen[600])),
                          TextSpan(text: ' e permaneça na posição correta.'),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 16),
                    child: RaisedButton(
                      child: Text('Gravar Posição Correta'),
                      onPressed: () {},
                      color: Colors.lightGreen[600],
                      textColor: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Relaxe a postura e permaneça na posição a ser corrigida',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 16),
                    child: RaisedButton(
                      child: Text('Gravar Posição de Alerta'),
                      onPressed: () {},
                      color: Colors.lightGreen[600],
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 64),
              Column(
                children: [
                  Text(
                    'Tempo',
                    style: theme.textTheme.subtitle1,
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: theme.textTheme.bodyText2,
                        children: [
                          TextSpan(text: 'Após quantos segundos na posição de alerta seu '),
                          TextSpan(text: 'Arretai', style: TextStyle(color: Colors.lightGreen[600])),
                          TextSpan(text: ' deve vibrar.'),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: TextFormField(
                      controller: timeController,
                      autovalidate: true,
                      validator: (str) => (int.tryParse(str) == null || int.tryParse(str) <= 0) && str.isNotEmpty
                          ? 'Tempo inválido'
                          : null,
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
                      ),
                    ),
                  ),
                  RaisedButton(
                    child: Text('Gravar Tempo'),
                    onPressed: saveTime,
                    color: Colors.lightGreen[600],
                    textColor: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
