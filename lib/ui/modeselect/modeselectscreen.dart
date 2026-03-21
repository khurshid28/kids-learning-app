import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_numbers_flutter/utils/color.dart';
import 'package:learn_numbers_flutter/utils/preference.dart';
import 'package:learn_numbers_flutter/utils/utils.dart';
import 'package:sizer/sizer.dart';

/// Shown once at app start – lets the child pick Numbers or Letters mode.
class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({Key? key}) : super(key: key);

  void _selectMode(BuildContext context, bool isLetters) async {
    await Preference.shared.setBool(Preference.isLettersMode, isLetters);
    Utils.playSound('assets/sounds/quiz/right_answer.mp3');
    Navigator.pushReplacementNamed(context, '/homeScreen');
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;

    return Scaffold(
      body: Sizer(
        builder: (context, orientation, deviceType) {
          return Stack(
            children: [
              // Background
              Image.asset(
                'assets/images/home/main_bg.webp',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
              SafeArea(
                bottom: Platform.isIOS ? false : true,
                top: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: h * 0.03),
                      child: Text(
                        'Choose Mode',
                        style: TextStyle(
                          fontFamily: 'MochiyPop',
                          fontWeight: FontWeight.w400,
                          fontSize: h * 0.07,
                          color: CColor.white,
                          shadows: const [
                            Shadow(
                              color: Colors.black38,
                              blurRadius: 6,
                              offset: Offset(2, 2),
                            )
                          ],
                        ),
                      ),
                    ),
                    // Two mode tiles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ModeTile(
                          label: 'Numbers',
                          iconPath: 'assets/icons/learn/numbers/b1.webp',
                          color: const Color(0xFFFFD54F),
                          borderColor: const Color(0xFFFFA000),
                          tileWidth: w * 0.28,
                          tileHeight: h * 0.72,
                          iconHeight: h * 0.46,
                          fontSize: h * 0.065,
                          onTap: () => _selectMode(context, false),
                        ),
                        SizedBox(width: w * 0.06),
                        _ModeTile(
                          label: 'Letters',
                          iconPath: 'assets/icons/learn/letters/ba.webp',
                          color: const Color(0xFF80DEEA),
                          borderColor: const Color(0xFF00838F),
                          tileWidth: w * 0.28,
                          tileHeight: h * 0.72,
                          iconHeight: h * 0.46,
                          fontSize: h * 0.065,
                          onTap: () => _selectMode(context, true),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ModeTile extends StatefulWidget {
  const _ModeTile({
    required this.label,
    required this.iconPath,
    required this.color,
    required this.borderColor,
    required this.tileWidth,
    required this.tileHeight,
    required this.iconHeight,
    required this.fontSize,
    required this.onTap,
  });

  final String label;
  final String iconPath;
  final Color color;
  final Color borderColor;
  final double tileWidth;
  final double tileHeight;
  final double iconHeight;
  final double fontSize;
  final VoidCallback onTap;

  @override
  _ModeTileState createState() => _ModeTileState();
}

class _ModeTileState extends State<_ModeTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.tileWidth,
          height: widget.tileHeight,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: widget.borderColor, width: 4),
            boxShadow: [
              BoxShadow(
                color: widget.borderColor.withOpacity(0.5),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                widget.iconPath,
                width: widget.tileWidth * 0.82,
                height: widget.iconHeight,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'MochiyPop',
                  fontWeight: FontWeight.w400,
                  fontSize: widget.fontSize,
                  color: CColor.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
