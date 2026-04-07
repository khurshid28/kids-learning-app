import 'dart:io';
import 'package:flutter/material.dart';
import 'package:learn_numbers_flutter/database/database_helper.dart';
import 'package:learn_numbers_flutter/database/tables/learn_numbers_table.dart';
import 'package:learn_numbers_flutter/utils/ad_helper.dart';
import 'package:learn_numbers_flutter/utils/color.dart';
import 'package:learn_numbers_flutter/utils/debug.dart';
import 'package:learn_numbers_flutter/utils/letters_data.dart';
import 'package:learn_numbers_flutter/utils/preference.dart';
import 'package:learn_numbers_flutter/utils/sizer_utils.dart';
import 'package:learn_numbers_flutter/utils/utils.dart';
import 'package:sizer/sizer.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({Key? key}) : super(key: key);

  @override
  _LearnScreenState createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> with WidgetsBindingObserver {
  List<LearnNumbersTable> listLearnNumbersData = [];
  List numbers = [];
  double runSpacing = 0;
  double spacing = 0;
  var columns = 0;
  double w = 0.0;
  bool isSongOnOff = false;
  bool isNumbersPlay = false;
  AudioPlayer? player;
  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.paused){
      if(isSongOnOff) {
        if (player != null) player!.stop();
      }else if(isNumbersPlay){
        isNumbersPlay = false;
        stopAllItemAnimation();
      }
    }else if(state == AppLifecycleState.resumed){
      if(isSongOnOff) {
        Utils.audioPlayer.stop();
        if (player != null) player!.play();
      }else if(!isNumbersPlay){
        Utils.audioPlayer.stop();
        isNumbersPlay = true;
        startAllItemAnimation();
      }else{
        Utils.audioPlayer.resume();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getLearnNumbersData();
    _createBottomBannerAd();
    player = AudioPlayer();
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
    final isLetters = Preference.shared.getBool(Preference.isLettersMode) ?? false;
    runSpacing = isLetters ? 4 : 8;
    spacing = isLetters ? 3 : 5;
    columns = isLetters ? 9 : 7;
    w = (MediaQuery.of(context).size.width - runSpacing * (columns - 1)) / columns;

    return Scaffold(
      body: Sizer(
        builder: (BuildContext context, Orientation orientation, DeviceType deviceType) {
          return Stack(
            children: [
              Image.asset("assets/images/learn/main_bg_learn_game.webp", fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
              SafeArea( bottom: (Platform.isIOS)?false:true,
                top: false,
                right: true,
                left: false,
                child: Column(
                  children: [
                    _widgetTopView(),
                    _widgetNumbersList(),
                    (_isBottomBannerAdLoaded)
                        ? SizedBox(
                      height: _bottomBannerAd.size.height.toDouble(),
                      width: _bottomBannerAd.size.width.toDouble(),
                      child: AdWidget(ad: _bottomBannerAd),
                    )
                        : Container()
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  _widgetTopView(){
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
          Expanded(child: Container()),
          InkWell(
            onTap: () {
              setState(() {
                isSongOnOff = !isSongOnOff;
                isNumbersPlay =false;
                if(isSongOnOff) {
                  Utils.audioPlayer.pause();
                  stopAllItemAnimation();
                  playSound("assets/sounds/learn/numbers_count_song.mp3");
                }else{
                  Utils.audioPlayer.resume();
                  stopSound();
                }
              });
            },
            child: Image.asset(
              (isSongOnOff)
                  ? "assets/icons/learn/ic_pause.webp"
                  : "assets/icons/learn/ic_play.webp",
              scale: 1.5,
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                isNumbersPlay = !isNumbersPlay;
                isSongOnOff =false;
                if(isNumbersPlay){
                  Utils.audioPlayer.pause();
                  player!.stop();
                  startAllItemAnimation();
                }else{
                  Utils.audioPlayer.resume();
                  stopAllItemAnimation();
                }
              });
            },
            child: Container(
              margin: EdgeInsets.only(left: Sizes.width_2),
              child: Image.asset(
                (isNumbersPlay)
                ?"assets/icons/learn/ic_song_off.webp"
                :"assets/icons/learn/ic_song_on.webp",
                scale: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _widgetNumbersList() {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: Sizes.height_1,bottom: Sizes.width_2,left: (Platform.isIOS) ? Sizes.width_4 :Sizes.width_1),
          child: Wrap(
            runSpacing: runSpacing,
            spacing: spacing,
            alignment: WrapAlignment.center,
            children: List.generate(listLearnNumbersData.length, (index) {
              final isLetters = Preference.shared.getBool(Preference.isLettersMode) ?? false;
              return SizedBox(
                width: w,
                height: isLetters ? w * 0.75 : w,
                child: _itemLeanNumbers(index),
              );
            }),
          ),
        ),
      ),
    );
  }

  _getLearnNumbersData() async {
    final isLetters = Preference.shared.getBool(Preference.isLettersMode) ?? false;
    if (isLetters) {
      for (int i = 0; i < LettersData.letters.length; i++) {
        final l = LettersData.letters[i];
        listLearnNumbersData.add(LearnNumbersTable(
          id: i + 1,
          categoryName: LettersData.iconPath(l),
          soundName: LettersData.soundPath(l),
        ));
      }
    } else {
      listLearnNumbersData = await DataBaseHelper().getAllLearnNumberData();
    }
    Debug.printLog("listLearnNumbersData==>> ${listLearnNumbersData.length}");
    numbers = List.generate(listLearnNumbersData.length, (index) => Container(color: CColor.black,));
    setState(() {});
  }



  void animationFadeInFadeOut(int index) {
    setState(() => listLearnNumbersData[index].opacity = 0);
    Future.delayed(
        const Duration(milliseconds: 500),
        () => setState(() {
              listLearnNumbersData[index].opacity = 1;
            }));
  }

  _itemLeanNumbers(int index) {
    return InkWell(
      onTap: () {
        if(!isSongOnOff && !isNumbersPlay) {
          animationFadeInFadeOut(index);
          Utils.playSound(
              listLearnNumbersData[index].soundName.toString());
        }
      },
      child: AnimatedOpacity(
        opacity: listLearnNumbersData[index].opacity,
        duration: const Duration(milliseconds: 500),
        child: Image.asset(
          listLearnNumbersData[index].categoryName.toString(),
          scale: 1.5,
        ),
      ),
    );
  }


  playSound(String soundName)async{
    if(player!.playing){
      player!.stop();
    }
    var duration = await player!.setAsset(soundName);
    Debug.printLog("playSound==>>> $soundName  $duration");
    player!.play();
  }

  stopSound(){
    if(player!.playing){
      player!.stop();
    }
  }

  var future = Future(() {});
  int pos = 0;

  startAllItemAnimation(){
    Debug.printLog("startAllItemAnimation==>>> ");

    if(isNumbersPlay && listLearnNumbersData.length > pos) {
      listLearnNumbersData[pos].player = AudioPlayer();

      if(mounted) {
        return Future.delayed(const Duration(milliseconds: 1500), () {
          setState(() {
            if (listLearnNumbersData[pos].opacity == 1) {
              playSoundFromList(
                  pos, listLearnNumbersData[pos].soundName.toString());
            }
            listLearnNumbersData[pos].opacity = 0;

            Future.delayed(const Duration(milliseconds: 500), () {
              listLearnNumbersData[pos].opacity = 1;
              pos++;
              startAllItemAnimation();
              // pos++;
            });
          });
        });
      }
    }else{
      isNumbersPlay = false;
      stopAllItemAnimation();
    }
  }

  playSoundFromList(int i,String soundName)async{
    Debug.printLog("playSoundFromList===>>> $soundName  $i");
    if( listLearnNumbersData[i].player!.playing){
      listLearnNumbersData[i].player!.stop();
    }
    listLearnNumbersData[i].player!.setAsset(soundName);
    listLearnNumbersData[i].player!.play().then((value) => {
    listLearnNumbersData[i].opacity = 0,
        listLearnNumbersData[i].opacity = 1
    });
  }
  stopAllItemAnimation(){
    Debug.printLog("stopAllItemAnimation==>>> $isNumbersPlay");
    if(!isNumbersPlay) {
      for (var i = 0; i < listLearnNumbersData.length; i++) {
        setState(() {
          listLearnNumbersData[i].opacity = 0;
          listLearnNumbersData[i].opacity = 1;
          if (listLearnNumbersData[i].player != null &&
              listLearnNumbersData[i].player!.playing) {
            listLearnNumbersData[i].player!.stop();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if(player != null) {
      player!.stop();
    }
    if(isNumbersPlay) {
      stopAllItemAnimation();
    }
    super.dispose();
  }


}

