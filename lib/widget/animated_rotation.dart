import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnimatedRotation extends ImplicitlyAnimatedWidget {
  final Widget child;
  final double rotation;
 
  AnimatedRotation({
    Key key,
    @required this.child,
    @required this.rotation,
    Curve curve = Curves.linear,
    Duration duration = const Duration(milliseconds: 300),
  })  : assert(child != null),
        assert(rotation != null && rotation >= 0 && rotation <= 1),
        super(key: key, curve: curve, duration: duration);

  @override
  _AnimatedRotationState createState() => _AnimatedRotationState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('rotation', rotation));
  }
}

class _AnimatedRotationState extends ImplicitlyAnimatedWidgetState<AnimatedRotation> {
  Tween<double> _rotation;
  Animation<double> _rotationAnimation;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _rotation = visitor(_rotation, widget.rotation, (dynamic value) => Tween<double>(begin: value));
  }

  @override
  void didUpdateTweens() {
    _rotationAnimation = animation.drive(_rotation);
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _rotationAnimation,
      child: widget.child,
    );
  }
}