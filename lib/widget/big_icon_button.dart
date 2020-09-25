import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BigIconButton extends StatelessWidget {
  final Widget label;
  final Widget icon;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadiusGeometry borderRadius;
  final double size;
  final Color color;
  final Color textColor;

  BigIconButton({
    @required this.label,
    @required this.icon,
    @required this.onPressed,
    this.padding,
    this.margin,
    this.borderRadius,
    this.size,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.zero.add(margin ?? EdgeInsets.zero),
      child: RawMaterialButton(
        fillColor: color ?? theme.buttonColor,
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4).add(padding ?? EdgeInsets.zero),
          child: Column(
            children: [
              DefaultTextStyle.merge(
                child: label,
                style: theme.textTheme.button.copyWith(
                  fontSize: size,
                  color: textColor,
                ),
              ),
              Theme(
                data: theme.copyWith(iconTheme: theme.iconTheme.copyWith(color: textColor)),
                child: icon,
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.circular(2)),
      ),
    );
  }
}
