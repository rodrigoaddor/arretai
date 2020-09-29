import 'package:arretai/widget/big_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Arretai',
          style: GoogleFonts.righteous(
            textStyle: theme.textTheme.headline6,
            color: Colors.lightGreen[600],
            fontSize: 40,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: IntrinsicWidth(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BigIconButton(
                label: Text('Conectar'),
                icon: Icon(Icons.bluetooth, size: 32),
                onPressed: () => Navigator.pushNamed(context, '/bluetooth'),
                size: 32,
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(8),
                color: Colors.teal[300],
                textColor: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              BigIconButton(
                label: Text('Personalizar'),
                icon: Icon(Icons.settings, size: 32),
                onPressed: () => Navigator.pushNamed(context, '/personalize'),
                size: 32,
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(8),
                color: Colors.lightGreen[600],
                textColor: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              SizedBox(height: 64),
              BigIconButton(
                label: Text('Ajuda'),
                icon: Icon(Icons.help_outline, size: 32),
                onPressed: () {},
                size: 32,
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(8),
                color: Colors.blueGrey[900],
                textColor: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
