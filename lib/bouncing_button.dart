import 'package:flutter/material.dart';

class BouncingButton extends StatefulWidget {
  final Widget child;
  final Function onPressed;

  const BouncingButton({Key? key, required this.child, required this.onPressed,})
      : super(key: key);

  @override
  _BouncingButtonState createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton>
    with SingleTickerProviderStateMixin {
  late double scale;
  late AnimationController _controller;
  late Color buttonColor;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 30),
        lowerBound: 0.0,
        upperBound: 0.1)
      ..addListener(() {
        setState(() {});
      });
    buttonColor = Colors.green;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _tapDown(TapDownDetails details) {
    _controller.forward();
    setState(() {
      buttonColor = Colors.lightGreen[300] as Color;
    });
  }

  void _tapUp(TapUpDetails details) {
    _controller.reverse();
    setState(() {
      buttonColor = Colors.green;
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    scale = 1 - _controller.value;
    return GestureDetector(
      onTapDown: _tapDown,
      onTapUp: _tapUp,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 100,
          height: 80,
          alignment: Alignment.center,
          //padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color:buttonColor,
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 10.0,
                offset: Offset(0.0, 5.0),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.child, // Original button text or widget
            ],
          ),
        ),
      ),
    );
  }
}
