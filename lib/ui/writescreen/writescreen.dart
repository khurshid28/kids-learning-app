import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:learn_numbers_flutter/utils/ad_helper.dart';
import 'package:learn_numbers_flutter/utils/color.dart';
import 'package:learn_numbers_flutter/utils/constant.dart';
import 'package:learn_numbers_flutter/utils/debug.dart';
import 'package:learn_numbers_flutter/utils/letters_data.dart';
import 'package:learn_numbers_flutter/utils/preference.dart';
import 'package:learn_numbers_flutter/utils/sizer_utils.dart';
import 'package:learn_numbers_flutter/utils/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';


class WriteScreen extends StatefulWidget {
  const WriteScreen({Key? key}) : super(key: key);

  @override
  _WriteScreenState createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController? _editingController;
  bool _isLettersMode = false;

  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;

  // ── Letters spelling game state ──
  String _currentLetter = '';
  String _currentWord = '';
  List<String> _wordChars = [];           // correct order
  List<String> _scrambledChars = [];      // shuffled tiles
  List<String?> _slots = [];             // placed letters (null = empty)
  List<bool> _scrambledUsed = [];         // which tiles are used
  bool _showCongrats = false;

  // Shake animation for wrong answer
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  int _shakeSlotIndex = -1;

  static const List<List<Color>> _bgGradients = [
    [Color(0xFFFFF9C4), Color(0xFFFFE082)],
    [Color(0xFFE1F5FE), Color(0xFFB3E5FC)],
    [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
    [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
    [Color(0xFFFCE4EC), Color(0xFFF8BBD9)],
    [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
    [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
    [Color(0xFFF9FBE7), Color(0xFFF0F4C3)],
  ];

  static const List<Color> _tileColors = [
    Color(0xFFEF5350),
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
    Color(0xFFFFA726),
    Color(0xFFAB47BC),
    Color(0xFF26C6DA),
    Color(0xFFEC407A),
    Color(0xFF8D6E63),
  ];

  @override
  void initState() {
    _editingController = TextEditingController();
    _isLettersMode =
        Preference.shared.getBool(Preference.isLettersMode) ?? false;
    if (_isLettersMode) _generateWord();
    _createBottomBannerAd();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 12)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reverse();
        }
        if (status == AnimationStatus.dismissed) {
          setState(() => _shakeSlotIndex = -1);
        }
      });

    super.initState();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _editingController!.dispose();
    super.dispose();
  }

  // ── Generate a new word for spelling ──
  void _generateWord() {
    final rng = Random();
    final idx = rng.nextInt(LettersData.letters.length);
    _currentLetter = LettersData.letters[idx];
    _currentWord =
        (LettersData.letterObjectNames[_currentLetter] ?? 'Apple').toUpperCase();
    _wordChars = _currentWord.split('');
    _scrambledChars = List.from(_wordChars)..shuffle();
    // Make sure it's actually shuffled
    while (_scrambledChars.length > 1 &&
        _scrambledChars.join() == _wordChars.join()) {
      _scrambledChars.shuffle();
    }
    _slots = List.filled(_wordChars.length, null);
    _scrambledUsed = List.filled(_wordChars.length, false);
    _showCongrats = false;
    setState(() {});
  }



  void _createBottomBannerAd() {
    _bottomBannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(
        nonPersonalizedAds: Utils.nonPersonalizedAds(),
      ),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBottomBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    if (Debug.googleAd) {
      _bottomBannerAd.load();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isLettersMode
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _bgGradients[
                          _currentLetter.isNotEmpty
                              ? _currentLetter.codeUnitAt(0) % _bgGradients.length
                              : 0],
                    ),
                  ),
                )
              : Image.asset(
                  "assets/images/write/bg.webp",
                  fit: BoxFit.fill,
                  height: double.infinity,
                  width: double.infinity,
                ),
          SafeArea(
              bottom: (Platform.isIOS) ? false : true,
              top: false,
              right: true,
              left: false,
              child: Column(
                children: [
                  _widgetTopView(),
                  _isLettersMode ? _letterSpellingGame() : _widgetCenterView(),
                  (_isBottomBannerAdLoaded)
                      ? SizedBox(
                    height: _bottomBannerAd.size.height.toDouble(),
                    width: _bottomBannerAd.size.width.toDouble(),
                    child: AdWidget(ad: _bottomBannerAd),
                  )
                      : Container()
                ],
              ))
        ],
      ),
    );
  }

  _widgetTopView() {
    return Container(
      margin: EdgeInsets.only(
          top: Sizes.height_1_5,
          left: (Platform.isIOS) ? Sizes.width_5 : Sizes.width_3,
          right: (Platform.isIOS) ? Sizes.width_5 : Sizes.width_3),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.asset(
              "assets/icons/learn/ic_home.webp",
              scale: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  LETTERS MODE — SPELLING GAME
  // ═══════════════════════════════════════════════════════════════════

  Widget _letterSpellingGame() {
    if (_showCongrats) {
      return Expanded(
        child: Lottie.asset('assets/animations/lottie/congrats.json'),
      );
    }
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Image + word name ──
          _spellingHeader(),
          SizedBox(height: Sizes.height_2),
          // ── Drop target slots ──
          _spellingSlots(),
          SizedBox(height: Sizes.height_3),
          // ── Scrambled draggable tiles ──
          _scrambledTiles(),
        ],
      ),
    );
  }

  /// Top section: object image only (no text)
  Widget _spellingHeader() {
    final objectImg = LettersData.letterObjects[_currentLetter];
    if (objectImg == null) return const SizedBox();
    return Image.asset(
      objectImg,
      height: Sizes.height_12,
      fit: BoxFit.contain,
    );
  }

  /// Row of drop-target slots
  Widget _spellingSlots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_wordChars.length, (i) {
        final filled = _slots[i] != null;
        final isShaking = _shakeSlotIndex == i;
        return AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            double offset = 0;
            if (isShaking) {
              offset = sin(_shakeAnimation.value * 3.14 * 2) *
                  _shakeAnimation.value;
            }
            return Transform.translate(
              offset: Offset(offset, 0),
              child: child,
            );
          },
          child: DragTarget<int>(
            onWillAcceptWithDetails: (_) => !filled,
            onAcceptWithDetails: (details) {
              _onDropLetter(details.data, i);
            },
            builder: (context, candidateData, rejectedData) {
              final isHovering = candidateData.isNotEmpty;
              return Container(
                width: Sizes.height_7,
                height: Sizes.height_7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: filled
                      ? Colors.green.shade100
                      : isHovering
                          ? Colors.yellow.shade100
                          : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: filled
                        ? Colors.green.shade700
                        : isHovering
                            ? Colors.orange
                            : const Color(0xFF90A4AE),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  filled ? _slots[i]! : '',
                  style: TextStyle(
                    fontFamily: 'MochiyPop',
                    fontWeight: FontWeight.w700,
                    fontSize: FontSize.size_22,
                    color: Colors.green.shade800,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  /// Scrambled letter tiles (draggable)
  Widget _scrambledTiles() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_scrambledChars.length, (i) {
        if (_scrambledUsed[i]) {
          // Empty placeholder for used tiles
          return Container(
            width: Sizes.height_6,
            height: Sizes.height_6,
            margin: const EdgeInsets.symmetric(horizontal: 4),
          );
        }
        final color = _tileColors[i % _tileColors.length];
        return Draggable<int>(
          data: i,
          feedback: Material(
            color: Colors.transparent,
            child: _buildTileWidget(_scrambledChars[i], color, scale: 1.15),
          ),
          childWhenDragging: Container(
            width: Sizes.height_6,
            height: Sizes.height_6,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
          ),
          child: _buildTileWidget(_scrambledChars[i], color),
        );
      }),
    );
  }

  Widget _buildTileWidget(String letter, Color color, {double scale = 1.0}) {
    return Container(
      width: Sizes.height_6 * scale,
      height: Sizes.height_6 * scale,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontFamily: 'MochiyPop',
          fontWeight: FontWeight.w700,
          fontSize: FontSize.size_20 * scale,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Called when a scrambled tile is dropped onto a slot.
  void _onDropLetter(int tileIndex, int slotIndex) {
    final droppedChar = _scrambledChars[tileIndex];
    final expectedChar = _wordChars[slotIndex];

    if (droppedChar == expectedChar) {
      // ✅ Correct!
      setState(() {
        _slots[slotIndex] = droppedChar;
        _scrambledUsed[tileIndex] = true;
      });
      Utils.playSound('assets/sounds/quiz/right_answer.mp3');

      // Check if word is complete
      if (!_slots.contains(null)) {
        // 🎉 All correct — celebrate!
        setState(() => _showCongrats = true);
        Utils.playSound('assets/sounds/matching/intelligent.mp3');
        Future.delayed(const Duration(seconds: 3), () {
          _generateWord();
        });
      }
    } else {
      // ❌ Wrong — shake & buzz
      Utils.playSound('assets/sounds/wrong.mp3');
      setState(() => _shakeSlotIndex = slotIndex);
      _shakeController.forward(from: 0);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  NUMBERS MODE — Original keyboard + blackboard
  // ═══════════════════════════════════════════════════════════════════

  Widget? _editTextField() {
    return Container(
      height: Sizes.height_100,
      margin: EdgeInsets.symmetric(horizontal: Sizes.width_2),
      child: TextField(
        autofocus: false,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        controller: _editingController,
        style: const TextStyle(
          color: CColor.white,
          fontSize: 40,
          fontFamily: "Digital",
          fontWeight: FontWeight.w400,
        ),
        cursorColor: CColor.black,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }

  _setTextOnBoard(String value) {
    if (value != Constant.strDas) {
      Utils.playSound("assets/sounds/learn/n_$value.mp3");
    }
    _editingController!.text = _editingController!.text + value;
  }

  _widgetCenterView() {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                  left: Sizes.width_5,
                  right: Sizes.width_5,
                  top: Sizes.height_1,
                  bottom: Sizes.height_2),
              decoration: const BoxDecoration(
                  color: CColor.black,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: _editTextField(),
            ),
          ),
          Container(
            margin:
                EdgeInsets.only(top: Sizes.height_1, bottom: Sizes.height_2),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          _setTextOnBoard(Constant.str1);
                        },
                        child: Image.asset(
                          "assets/icons/write/n1.webp",
                          scale: 1.5,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _setTextOnBoard(Constant.str2);
                        },
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: Sizes.width_3),
                          child: Image.asset(
                            "assets/icons/write/n2.webp",
                            scale: 1.5,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _setTextOnBoard(Constant.str3);
                        },
                        child: Image.asset(
                          "assets/icons/write/n3.webp",
                          scale: 1.5,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          _setTextOnBoard(Constant.str4);
                        },
                        child: Image.asset(
                          "assets/icons/write/n4.webp",
                          scale: 1.5,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _setTextOnBoard(Constant.str5);
                        },
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: Sizes.width_3),
                          child: Image.asset(
                            "assets/icons/write/n5.webp",
                            scale: 1.5,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _setTextOnBoard(Constant.str6);
                        },
                        child: Image.asset(
                          "assets/icons/write/n6.webp",
                          scale: 1.5,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          _setTextOnBoard(Constant.str7);
                        },
                        child: Image.asset(
                          "assets/icons/write/n7.webp",
                          scale: 1.5,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _setTextOnBoard(Constant.str8);
                        },
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: Sizes.width_3),
                          child: Image.asset(
                            "assets/icons/write/n8.webp",
                            scale: 1.5,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _setTextOnBoard(Constant.str9);
                        },
                        child: Image.asset(
                          "assets/icons/write/n9.webp",
                          scale: 1.5,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          _setTextOnBoard(Constant.strDas);
                        },
                        child: Image.asset(
                          "assets/icons/write/n_das.webp",
                          scale: 1.5,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _setTextOnBoard(Constant.str10);
                        },
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: Sizes.width_3),
                          child: Image.asset(
                            "assets/icons/write/n10.webp",
                            scale: 1.5,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (_editingController!.text.isNotEmpty) {
                            var str = _editingController!.text
                                .toString()
                                .substring(
                                    0,
                                    _editingController!.text.toString().length -
                                        1);
                            _editingController!.text = str;
                          }
                        },
                        child: Image.asset(
                          "assets/icons/write/nb.webp",
                          scale: 1.5,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
