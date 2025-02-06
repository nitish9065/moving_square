import 'dart:developer';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Padding(
        padding: EdgeInsets.all(32.0),
        child: SquareAnimation(),
      ),
    );
  }
}

/// Moving Square widget
class SquareAnimation extends StatefulWidget {
  const SquareAnimation({super.key});

  @override
  State<SquareAnimation> createState() {
    return SquareAnimationState();
  }
}

class SquareAnimationState extends State<SquareAnimation>
    with SingleTickerProviderStateMixin {
  static const _squareSize = 50.0;

  // animations to control smooth transitioning of square.
  late AnimationController _animationController;
  late Animation<double> _animation;

  // initially should be in center
  late double _currentPosition;

  // will be fetched dynamically based on screen sizes for responsiveness
  late Size _screenSize;
  late double _screenWidth;
  late double _screenHeight;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animationController.addListener(_animationListener);
  }

  // Need to override this method inorder to avoid error widget complaining about
  // initialization of Inhherited Widget changes
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenSize = MediaQuery.of(context).size;

    // To make up with the padding around the SquareAnimation Widget class,
    // have to subtract the padding from width & height
    _screenWidth = _screenSize.width - 64.0;
    _screenHeight = _screenSize.height - 64.0;
    _currentPosition = _centeredPosition;
  }

  void _animationListener() {
    setState(() {
      _currentPosition = _animation.value;
    });
  }

  @override
  void dispose() {
    _animationController.removeListener(_animationListener);
    _animationController.dispose();
    super.dispose();
  }

  void _startsMoving(double targetPostion) {
    if (_animationController.isAnimating) {
      return;
    }
    log('moving from $_currentPosition to $targetPostion');
    _animation = Tween<double>(
      begin: _currentPosition,
      end: targetPostion,
    ).animate(
      _animationController,
    );

    _animationController.reset();
    _animationController.forward();
  }

  double get _centeredPosition => ((_screenWidth / 2) - (_squareSize / 2));
  bool get isSquareCentered => _currentPosition == _centeredPosition;
  bool get isSquareMoving => _animationController.isAnimating;
  bool get isRightEndReached => _currentPosition <= 0;
  bool get isLeftEndReached => _currentPosition >= _screenWidth - _squareSize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amberAccent,
      body: Stack(
        children: [
          Positioned(
            top: _screenHeight / 2 -
                _squareSize /
                    2, // make the container inbetween the height of teh screen
            right: _currentPosition, // initially at center from right
            child: Container(
              width: _squareSize,
              height: _squareSize,
              decoration: BoxDecoration(
                color: Colors.red,
                border: Border.all(),
              ),
            ),
          ),
          Positioned(
            bottom: kToolbarHeight,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: !isSquareMoving && !isLeftEndReached
                      ? () {
                          _startsMoving(_screenWidth - _squareSize);
                        }
                      : null,
                  label: const Text('Left'),
                ),
                const SizedBox(
                  width: 8.0,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: !isSquareMoving && !isRightEndReached
                      ? () {
                          _startsMoving(0);
                        }
                      : null,
                  label: const Text('Right'),
                ),
                const SizedBox(
                  width: 8.0,
                ),
                ElevatedButton.icon(
                  onPressed: !isSquareMoving && !isSquareCentered
                      ? () {
                          _startsMoving(_centeredPosition);
                        }
                      : null,
                  label: const Text('Reset'),
                  icon: const Icon(Icons.center_focus_strong),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
