import 'package:arretai/data/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

class TimeDialog extends StatefulWidget {
  @override
  _TimeDialogState createState() => _TimeDialogState();
}

class _TimeDialogState extends State<TimeDialog> {
  TextEditingController controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    controller = TextEditingController(text: context.read<AppState>().time?.toString() ?? '')
      ..addListener(() => setState(() {}));
  }

  void save(BuildContext context) {
    if (!Form.of(context).validate()) return;

    final state = context.read<AppState>();
    state.time = int.tryParse(controller.text) ?? 0;
    Navigator.pop(context, state.time);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Builder(
        builder: (context) => AlertDialog(
          title: Text('Definir tempo na posição de alerta para vibrar'),
          content: TextFormField(
            controller: controller,
            autovalidate: false,
            validator: (str) => (int.tryParse(str) == null || int.tryParse(str) <= 0) ? 'Tempo inválido' : null,
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
                hintText: '${context.watch<AppState>().time ?? 0}',
                floatingLabelBehavior: FloatingLabelBehavior.always),
          ),
          actions: [
            FlatButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text('Salvar'),
              onPressed: () => save(context),
            ),
          ],
        ),
      ),
    );
  }
}
