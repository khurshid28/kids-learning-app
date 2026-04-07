import 'dart:io';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:learn_numbers_flutter/localization/language/languages.dart';
import 'package:learn_numbers_flutter/ui/quizscreen/quizscreen.dart';
import 'package:learn_numbers_flutter/utils/ad_helper.dart';
import 'package:learn_numbers_flutter/utils/color.dart';
import 'package:learn_numbers_flutter/utils/debug.dart';
import 'package:learn_numbers_flutter/utils/letters_data.dart';
import 'package:learn_numbers_flutter/utils/preference.dart';
import 'package:learn_numbers_flutter/utils/sizer_utils.dart';
import 'package:learn_numbers_flutter/utils/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({Key? key}) : super(key: key);

  @override
  _PracticeScreenState createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {

  static const List<List<Color>> _letterBgGradients = [
    [Color(0xFFFFF9C4), Color(0xFFFFE082)],
    [Color(0xFFE1F5FE), Color(0xFFB3E5FC)],
    [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
    [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
    [Color(0xFFFCE4EC), Color(0xFFF8BBD9)],
    [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
    [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
    [Color(0xFFF9FBE7), Color(0xFFF0F4C3)],
    [Color(0xFFE8EAF6), Color(0xFFC5CAE9)],
    [Color(0xFFFBE9E7), Color(0xFFFFCCBC)],
  ];

  bool _isLettersMode = false;
  List<PracticeNumberData> answerNumbersList = [];
  int? originalAnswer = 0;
  final FlutterTts _flutterTts = FlutterTts();
  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;


  @override
  void initState() {
    _isLettersMode = Preference.shared.getBool(Preference.isLettersMode) ?? false;
    _generatePractice();
    _createBottomBannerAd();
    super.initState();
  }

  /// The main question image shown in the large box.
  /// Letters mode: shows the object image (e.g. apple for A) → kid picks the letter.
  /// Numbers mode: shows the count image (obj3.png) → kid picks the number.
  Widget _questionImage() {
    if (_isLettersMode && originalAnswer != null && originalAnswer! > 0) {
      final letter = LettersData.letters[originalAnswer! - 1];
      return Stack(
        alignment: Alignment.topRight,
        children: [
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                LettersData.letterObjects[letter]!,
                fit: BoxFit.contain,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              final name = LettersData.letterObjectNames[letter] ?? letter;
              Utils.textToSpeech(name, _flutterTts);
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: CColor.orange.withOpacity(0.90),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 28),
            ),
          ),
        ],
      );
    }
    if (!_isLettersMode && originalAnswer != null && originalAnswer! > 0) {
      return Image.asset(
        'assets/images/practice/obj$originalAnswer.png',
        scale: 2.5,
      );
    }
    return Container();
  }

  /// Display label for an answer option.
  String _answerLabel(int count) {
    if (_isLettersMode) {
      return LettersData.letters[count - 1].toUpperCase();
    }
    return count.toString();
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
                    colors: _letterBgGradients[
                        ((originalAnswer ?? 0) - 1).clamp(0, 25) %
                            _letterBgGradients.length],
                  ),
                ),
              )
            : Image.asset(
                "assets/images/practice/bg.webp",
                fit: BoxFit.cover,
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
                _widgetCountObjet(),
                (_isBottomBannerAdLoaded)
                    ? SizedBox(
                  height: _bottomBannerAd.size.height.toDouble(),
                  width: _bottomBannerAd.size.width.toDouble(),
                  child: AdWidget(ad: _bottomBannerAd),
                )
                    : Container()
              ],
            ),
          ),
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
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: Sizes.width_15),
              alignment: Alignment.center,
              child: AutoSizeText(
                _isLettersMode ? "Which letter is this? 🤔" : Languages.of(context)!.txtCountObj,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "MochiyPop",
                  fontWeight: FontWeight.w400,
                  color: CColor.black,
                  fontSize: FontSize.size_20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _widgetCountObjet() {
    if (_isLettersMode) {
      return Expanded(
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                margin: EdgeInsets.only(
                    right: Sizes.width_2,
                    left: Sizes.width_4,
                    bottom: Sizes.height_2_5,
                    top: Sizes.height_1),
                decoration: BoxDecoration(
                    border: Border.all(color: CColor.mainBorder, width: 10),
                    borderRadius: BorderRadius.circular(30),
                    color: CColor.mainBg),
                child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: Sizes.width_1, vertical: Sizes.height_1),
                  decoration: BoxDecoration(
                      border: Border.all(color: CColor.innerBorder, width: 10),
                      borderRadius: BorderRadius.circular(25),
                      color: CColor.innerBg),
                  child: _questionImage(),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                margin: EdgeInsets.only(
                    bottom: Sizes.height_2_5,
                    top: Sizes.height_1,
                    right: Sizes.width_4),
                child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 2.2),
                    itemCount: answerNumbersList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _itemAnswerNumbers(index, context);
                    }),
              ),
            ),
          ],
        ),
      );
    }
    return Expanded(
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: Container(
              margin: EdgeInsets.only(
                right: Sizes.width_2,
                  left: Sizes.width_6,
                  bottom: Sizes.height_2_5,
                  top: Sizes.height_1),
              decoration: BoxDecoration(
                  border: Border.all(color: CColor.mainBorder, width: 10),
                  borderRadius: BorderRadius.circular(30),
                  color: CColor.mainBg),
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: Sizes.width_2, vertical: Sizes.height_1),
                decoration: BoxDecoration(
                    border: Border.all(color: CColor.innerBorder, width: 10),
                    borderRadius: BorderRadius.circular(25),
                    color: CColor.innerBg),
                child: _questionImage(),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.only(bottom: (Platform.isAndroid) ? Sizes.height_1 : 0,
                  right: (Platform.isAndroid) ? Sizes.width_2 : 0),
              child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:1,
                      mainAxisSpacing: 5,
                      childAspectRatio: 2.5),
                  itemCount: answerNumbersList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _itemAnswerNumbers(index, context);
                  }),
            ),
          )
        ],
      ),
    );
  }


  /// Builds a styled word widget for letters mode:
  /// First letter is BIG + colored, remaining letters are smaller + black.
  Widget _styledLetterWord(String word, Color accentColor) {
    if (word.isEmpty) return const SizedBox();
    final firstChar = word[0].toUpperCase();
    final rest = word.substring(1).toLowerCase();
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          firstChar,
          style: TextStyle(
            fontFamily: "MochiyPop",
            fontWeight: FontWeight.w700,
            color: accentColor,
            fontSize: FontSize.size_22,
          ),
        ),
        Text(
          rest,
          style: TextStyle(
            fontFamily: "MochiyPop",
            fontWeight: FontWeight.w400,
            color: CColor.black,
            fontSize: FontSize.size_14,
          ),
        ),
      ],
    );
  }

  /// Accent colors for the first letter in answer options.
  static const List<Color> _letterAccentColors = [
    Color(0xFFE53935), // red
    Color(0xFF1E88E5), // blue
    Color(0xFF43A047), // green
    Color(0xFFFB8C00), // orange
  ];

  _itemAnswerNumbers(int index, BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          if(answerNumbersList[index].onTapRightAnswer){
            Utils.playSound("assets/sounds/quiz/right_answer.mp3");
            _generatePractice();
          }else{
            Utils.playSound("assets/sounds/wrong.mp3");
          }
        });
      },
      child: Container(
        alignment: Alignment.center,
        padding: _isLettersMode ? const EdgeInsets.symmetric(horizontal: 6) : null,
        decoration: BoxDecoration(
            border: Border.all(color: CColor.black, width: 5),
            borderRadius: BorderRadius.circular(15),
            color: CColor.boxColorArray[index % CColor.boxColorArray.length]),
        child: _isLettersMode
            ? _buildLetterAnswerContent(index)
            : AutoSizeText(
                _answerLabel(answerNumbersList[index].count!),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "MochiyPop",
                  fontWeight: FontWeight.w400,
                  color: CColor.black,
                  fontSize: FontSize.size_20,
                ),
              ),
      ),
    );
  }

  /// Builds the content of an answer button in letters mode:
  /// Big colored letter + remaining letters small (e.g. C + ar)
  Widget _buildLetterAnswerContent(int index) {
    final count = answerNumbersList[index].count!;
    final letter = LettersData.letters[count - 1];
    final objectName = LettersData.letterObjectNames[letter] ?? '';
    final accentColor = _letterAccentColors[index % _letterAccentColors.length];
    final rest = objectName.length > 1 ? objectName.substring(1).toLowerCase() : '';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          letter.toUpperCase(),
          style: TextStyle(
            fontFamily: "MochiyPop",
            fontWeight: FontWeight.w700,
            color: accentColor,
            fontSize: FontSize.size_22,
          ),
        ),
        if (rest.isNotEmpty)
          Flexible(
            child: Text(
              rest,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: "MochiyPop",
                fontWeight: FontWeight.w400,
                color: CColor.black,
                fontSize: FontSize.size_12,
              ),
            ),
          ),
      ],
    );
  }

  _generatePractice() {
    originalAnswer = 0;
    answerNumbersList.clear();

    final int maxVal = _isLettersMode ? 26 : 20;
    var rng = Random();
    var generateRandomNumber = rng.nextInt(maxVal) + 1;
    originalAnswer = generateRandomNumber;
    answerNumbersList.add(PracticeNumberData(generateRandomNumber, true));

    for (int j = 0; j < 3; j++) {
      var randomNumber = RandomInt.generate(max: maxVal, min: 1);
      if(randomNumber == generateRandomNumber){
        final nextNum = (randomNumber % maxVal) + 1;
        answerNumbersList.add(PracticeNumberData(nextNum, false));
      }else {
        answerNumbersList.add(PracticeNumberData(randomNumber, false));
      }
    }

    answerNumbersList.shuffle();
    setState(() {});

    // Play letter sound after generating so kids hear the object's letter
    if (_isLettersMode && originalAnswer != null && originalAnswer! > 0) {
      final letter = LettersData.letters[originalAnswer! - 1];
      Future.delayed(const Duration(milliseconds: 300), () {
        Utils.playSound(LettersData.soundPath(letter));
      });
    }
  }


}

class PracticeNumberData{
  int? count;
  bool onTapRightAnswer = false;

  PracticeNumberData(this.count,this.onTapRightAnswer);
}
