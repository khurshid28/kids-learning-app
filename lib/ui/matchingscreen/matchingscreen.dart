import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:learn_numbers_flutter/utils/ad_helper.dart';
import 'package:learn_numbers_flutter/utils/letters_data.dart';
import 'package:learn_numbers_flutter/utils/preference.dart';
import 'package:learn_numbers_flutter/utils/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:learn_numbers_flutter/utils/color.dart';
import 'package:learn_numbers_flutter/utils/debug.dart';
import 'package:learn_numbers_flutter/utils/sizer_utils.dart';
import 'package:collection/collection.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({Key? key}) : super(key: key);

  @override
  _MatchingScreenState createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  String? _targetImageUrl;

  List<DraggableNumbersData> draggableNumbers = [];
  var quizAnswer = 0;
  var selectedIndex = 0;

  bool? isDrag = false;

  bool _isLettersMode = false;

  Map<String, String> totalNumbers = {
    "1": "assets/icons/learn/numbers/b1.webp",
    "2": "assets/icons/learn/numbers/b2.webp",
    "3": "assets/icons/learn/numbers/b3.webp",
    "4": "assets/icons/learn/numbers/b4.webp",
    "5": "assets/icons/learn/numbers/b5.webp",
    "6": "assets/icons/learn/numbers/b6.webp",
    "7": "assets/icons/learn/numbers/b7.webp",
    "8": "assets/icons/learn/numbers/b8.webp",
    "9": "assets/icons/learn/numbers/b9.webp",
    "10": "assets/icons/learn/numbers/b10.webp",
    "11": "assets/icons/learn/numbers/b11.webp",
    "12": "assets/icons/learn/numbers/b12.webp",
    "13": "assets/icons/learn/numbers/b13.webp",
    "14": "assets/icons/learn/numbers/b14.webp",
    "15": "assets/icons/learn/numbers/b15.webp",
    "16": "assets/icons/learn/numbers/b16.webp",
    "17": "assets/icons/learn/numbers/b17.webp",
    "18": "assets/icons/learn/numbers/b18.webp",
    "19": "assets/icons/learn/numbers/b19.webp",
    "20": "assets/icons/learn/numbers/b20.webp",
  };


  List<String> option = [];
  List<String> que = [];
  Set<String> count = {};

  bool? accept = false;
  bool isLottieLoad = false;
  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;



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
  void initState() {
    _isLettersMode = Preference.shared.getBool(Preference.isLettersMode) ?? false;
    if (_isLettersMode) {
      totalNumbers = LettersData.objectMap;
    }
    generateNumbers();
    _createBottomBannerAd();
    super.initState();
  }

  /// Returns the display image shown inside the drag-target box.
  String _targetDisplayImage(int index) {
    if (_isLettersMode) {
      // que[index] = object image path e.g. "assets/images/letters/a.webp"
      final letter = que[index]
          .split('assets/images/letters/')
          .last
          .replaceAll('.webp', '');
      return LettersData.iconPath(letter); // show letter badge in target box
    }
    // Numbers mode: show count image extracted from icon path
    return 'assets/images/count/imgCount/count_${que[index].split('assets/icons/learn/numbers/b').last}';
  }

  /// Extracts the letter key from an object image path.
  String _letterFromObjectPath(String path) {
    return path.split('assets/images/letters/').last.replaceAll('.webp', '');
  }

  /// Returns the hint text for a draggable item in letters mode:
  /// The object name WITHOUT the first letter. e.g. Zebra → "ebra"
  String _letterHintText(String letter) {
    final name = LettersData.letterObjectNames[letter] ?? '';
    if (name.length <= 1) return '';
    return name.substring(1).toLowerCase();
  }

  /// Accent colors for the first letter in drag targets.
  static const List<Color> _matchLetterColors = [
    Color(0xFF1565C0), // blue
    Color(0xFF2E7D32), // green
    Color(0xFF7B1FA2), // purple
  ];

  /// Sound played when dragging an item.
  void _playDragSound(String key) {
    if (_isLettersMode) {
      Utils.playSound(LettersData.soundPath(key));
    } else {
      final iconPath = totalNumbers[key]!;
      final num = iconPath.split('assets/icons/learn/numbers/b').last.replaceAll('.webp', '');
      Utils.playSound('assets/sounds/learn/n_$num.mp3');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: (Platform.isIOS) ? false : true,
        top: false,
        right: false,
        left: false,
        child: Stack(
          children: [
            Image.asset(
              "assets/images/matching/matching_bg.webp",
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
            Column(
              mainAxisAlignment: _isLettersMode
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.spaceAround,
              children: [
                _widgetTopView(),
                if(isLottieLoad)...{
                  Expanded(
                    child:Lottie.asset('assets/animations/lottie/congrats.json'),
                  )
                }else...{
                  _draggablesGridView(),
                  _dragTargetsGridView(),
                },
                (_isBottomBannerAdLoaded)
                    ? SizedBox(
                  height: _bottomBannerAd.size.height.toDouble(),
                  width: _bottomBannerAd.size.width.toDouble(),
                  child: AdWidget(ad: _bottomBannerAd),
                )
                    : Container()
              ],
            ),
          ],
        ),
      ),
    );
  }

  _widgetTopView() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(
        top: Sizes.height_1_5,
        bottom: 0,
        left: (Platform.isIOS) ? Sizes.width_5 : Sizes.width_2,
      ),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Image.asset(
          "assets/icons/learn/ic_home.webp",
          scale: _isLettersMode ? 7 : 6,
        ),
      ),
    );
  }

  _dragTargetsGridView() {
    return Expanded(
      child: GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics: _isLettersMode
              ? const NeverScrollableScrollPhysics()
              : null,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: _isLettersMode ? 8 : 35,
              mainAxisSpacing: _isLettersMode ? 2 : 30,
              childAspectRatio: _isLettersMode ? 0.85 : 0.92),
          itemCount: que.length,
          itemBuilder: (BuildContext context, int index) {
            return _dragTargets(index, context);
          }),
    );
  }

  _dragTargets(int index, BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        DragTarget(
          builder: (BuildContext context, List<Object?> candidateData,
              List<dynamic> rejectedData) {
            return count.contains(totalNumbers.keys.firstWhere((element) => totalNumbers[element] == que[index]))
                ? Image.asset(
                    getHappyBoxesFromIndex(index)!,
                    fit: BoxFit.cover,
                    height: _isLettersMode ? Sizes.height_13 : Sizes.height_17,
                  )
                : Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  getEmptyBoxesFromIndex(index)!,
                  fit: BoxFit.cover,
                  height: _isLettersMode ? Sizes.height_13 : Sizes.height_17,
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: Sizes.height_2_5,
                    left: Sizes.width_1_5,
                  ),
                  child: _isLettersMode
                      ? Text(
                          _letterFromObjectPath(que[index]).toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'MochiyPop',
                            fontWeight: FontWeight.w700,
                            fontSize: FontSize.size_40,
                            color: _matchLetterColors[index % _matchLetterColors.length],
                          ),
                        )
                      : Image.asset(
                          _targetDisplayImage(index),
                          fit: BoxFit.contain,
                          height: Sizes.height_8,
                        ),
                ),
              ],
            );
          },
          onWillAcceptWithDetails: (details) {
            if (totalNumbers[details.data] == que[index]) {
              // Utils.playSound("assets/sounds/matching/intelligent.mp3");
              Debug.printLog("accept");
              return true;
            } else {
              // Utils.playSound("assets/sounds/quiz/wrong_answer.mp3");
              Debug.printLog("reject");
              return false;
            }
          },
          onAcceptWithDetails: (details) async {
            setState(() {
              accept = true;
            });
            if (count.length < 3) {
              setState(() {
                count.add(details.data.toString());
                Debug.printLog("que:==>>  ${que[index]}");
                Utils.playSound("assets/sounds/matching/intelligent.mp3");
              });

              await Future.delayed(const Duration(milliseconds: 100), () {
                setState(() {
                  accept = false;
                });
              });
            }

            if(count.length == 3){
              isLottieLoad = true;

              await Future.delayed(const Duration(seconds:3), () {
                setState(() {
                  isLottieLoad = false;
                  generateNumbers();
                });
              });
            }
          },

          onLeave: (data) {
            Future.delayed(const Duration(milliseconds: 100), () {
              if (!isDrag!) {
                Debug.printLog("onLeave==>>>> $data  $isDrag");
                Utils.playSound("assets/sounds/quiz/wrong_answer.mp3");
              }
            });

            // Utils.playSound("assets/sounds/quiz/wrong_answer.mp3");
          },
        ),
      ],
    );
  }


  _draggablesGridView() {
    if (_isLettersMode) {
      // Use a simple Row with fixed height — no wasted vertical space
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(option.length, (index) {
            return _draggables(index, context);
          }),
        ),
      );
    }
    return GridView.builder(
        padding: const EdgeInsets.all(5),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 70,
            mainAxisSpacing: 25,
            childAspectRatio: 3),
        itemCount: option.length,
        itemBuilder: (BuildContext context, int index) {
          return _draggables(index, context);
        });
  }

  String? current;
  _draggables(int index, BuildContext context) {
    return Container(
      alignment: _isLettersMode
          ? Alignment.center
          : (index == 0)
              ? Alignment.centerRight
              : (index == 2)
                  ? Alignment.centerLeft
                  : Alignment.center,
      child: Draggable(
        maxSimultaneousDrags: accept! || isDrag! ? 0 : 1,
        onDragStarted: () {
          setState(() {
            isDrag = true;
            current = totalNumbers[option[index]];
            _playDragSound(option[index]);
            Debug.printLog("current: ${current!}");
          });
        },
        onDragEnd: (_) {
          setState(() {
            isDrag = false;
          });
        },
        data: option[index],
        feedback: count.contains(option[index])? Container(
          color: CColor.black,
          height: MediaQuery.of(context).size.height * 0.05,
          width: MediaQuery.of(context).size.width * 0.33,
        ) :
        _isLettersMode
            ? Material(
                color: Colors.transparent,
                child: _buildLetterDraggableFeedback(index, context),
              )
            : Image.asset(
                totalNumbers[option[index]].toString(),
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.width * 0.2,
              )
        ,
        childWhenDragging: count.contains(option[index])
            ? Container(
                color: CColor.transparent,
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.width * 0.33,
              )
            : _isLettersMode
                ? Opacity(
                    opacity: 0.3,
                    child: _buildLetterDraggableChild(index),
                  )
                : Container(
                    color: CColor.transparent,
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.33,
                  ),

        child: count.contains(option[index])
            ? _isLettersMode
                ? Opacity(
                    opacity: 0,
                    child: _buildLetterDraggableChild(index),
                  )
                : Container(
                    color: CColor.transparent,
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.33,
                  )
            : _isLettersMode
                ? _buildLetterDraggableChild(index)
                : Image.asset(
                    totalNumbers[option[index]].toString(),
                  ),
      ),
    );
  }


  String? getEmptyBoxesFromIndex(int index) {
    var imgName = "";
    if (index == 0) {
      imgName = "assets/images/matching/box_blue.webp";
    } else if (index == 1) {
      imgName = "assets/images/matching/box_green.webp";
    } else if (index == 2) {
      imgName = "assets/images/matching/box_purple.webp";
    }
    return imgName;
  }


  String? getHappyBoxesFromIndex(int index) {
    var imgName = "";
    if (index == 0) {
      imgName = "assets/images/matching/box_blue_happy.webp";
    } else if (index == 1) {
      imgName = "assets/images/matching/box_green_happy.webp";
    } else if (index == 2) {
      imgName = "assets/images/matching/box_purple_happy.webp";
    }
    return imgName;
  }

  /// Builds the draggable child widget for letters mode:
  /// Shows object image + remaining letters side by side (e.g. 🌞 "un")
  Widget _buildLetterDraggableChild(int index) {
    final letter = option[index];
    final objectImg = totalNumbers[letter]!;
    final hint = _letterHintText(letter);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          objectImg,
          height: MediaQuery.of(context).size.height * 0.1,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 4),
        Text(
          hint,
          style: TextStyle(
            fontFamily: 'MochiyPop',
            fontWeight: FontWeight.w700,
            fontSize: FontSize.size_20,
            color: const Color(0xFF37474F),
          ),
        ),
      ],
    );
  }

  /// Builds the feedback widget shown while dragging in letters mode.
  /// Shows image + hint text (bigger version).
  Widget _buildLetterDraggableFeedback(int index, BuildContext context) {
    final letter = option[index];
    final objectImg = totalNumbers[letter]!;
    final hint = _letterHintText(letter);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          objectImg,
          height: MediaQuery.of(context).size.height * 0.1,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 4),
        Text(
          hint,
          style: TextStyle(
            fontFamily: 'MochiyPop',
            fontWeight: FontWeight.w700,
            fontSize: FontSize.size_20,
            color: const Color(0xFF37474F),
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  generateNumbers() {
    Utils.playSound("assets/sounds/matching/matchingpair.mp3");
    option.clear();
    que.clear();
    count.clear();

    option = totalNumbers.keys.toList().sample(3);
    Debug.printLog("New Matching Numbers==>> $option");
    for (var element in option) {
      que.add(totalNumbers[element]!);
      Debug.printLog("Total Numbers Element==>>> $element  ${totalNumbers[element]}");
    }
    que.shuffle();

    setState(() {});

  }

}

class DraggableNumbersData {
  int? count;
  bool isSelect = false;

  DraggableNumbersData(this.count, this.isSelect);
}
