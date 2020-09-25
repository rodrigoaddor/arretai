import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String body;
  final String cancelText;
  final String confirmText;

  ConfirmDialog({
    @required this.title,
    this.body,
    this.cancelText = 'Cancelar',
    this.confirmText = 'Confirmar',
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(title),
        content: body != null ? Text(body) : null,
        contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 12),
        actions: [
          FlatButton(
            child: Text(cancelText),
            onPressed: () => Navigator.pop(context, false),
          ),
          FlatButton(
            child: Text(confirmText),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      );
}