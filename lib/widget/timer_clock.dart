import 'package:flutter/material.dart';

class TimerClock extends StatefulWidget {
  final Duration duration;
  final VoidCallback onDone;
  final Duration doneDuration;
  final Widget done;

  TimerClock({
    @required this.duration,
    @required this.onDone,
    @required this.done,
    this.doneDuration = const Duration(seconds: 2),
  });

  @override
  _TimerClockState createState() => _TimerClockState();
}

class _TimerClockState extends State<TimerClock> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> timerAnimation;

  bool showingDone = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          if (mounted) {
            setState(() => showingDone = true);
            widget.onDone();
          }
          await Future.delayed(widget.doneDuration);
          if (mounted) Navigator.pop(context);
        }
      });

    timerAnimation = Tween(begin: 0.0, end: 1.0).animate(controller);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.forward();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = theme.textTheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedOpacity(
          duration: Duration(milliseconds: 150),
          opacity: showingDone ? 0 : 1,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text('Posicione-se!', style: texts.headline6),
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation.drive(CurveTween(curve: Curves.easeInOutBack)),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
          child: showingDone
              ? widget.done
              : AnimatedBuilder(
                  animation: timerAnimation,
                  builder: (context, child) => Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.fromSize(
                        size: Size.square(64),
                        child: CircularProgressIndicator(
                          value: timerAnimation.value,
                          valueColor: AlwaysStoppedAnimation(Colors.lightGreen[600]),
                        ),
                      ),
                      Text(
                        Tween(begin: 3.0, end: 0.0).transform(timerAnimation.value).ceil().toString(),
                        style: texts.headline4,
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
