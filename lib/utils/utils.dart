import 'dart:io';
import 'package:learn_numbers_flutter/utils/constant.dart';
import 'package:learn_numbers_flutter/utils/preference.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'color.dart';
import 'debug.dart';
import 'sizer_utils.dart';

class Utils {

  static showToast(BuildContext context, String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        textColor: CColor.white,
        fontSize: FontSize.size_14);
  }

  static playSound(String soundName) async {
    soundName = soundName.replaceAll("assets/", "");
    audioPlayer = AudioPlayer();
    audioPlayer.play(AssetSource(soundName));
    audioPlayer.resume();
    // AudioPlayer audioPlayer = AudioPlayer();
    // AudioCache audioCache = AudioCache(fixedPlayer: audioPlayer);
    // audioCache.play(soundName);
  }

  static Future<void> playSoundTouchNumber(String soundName) async {
    soundName = soundName.replaceAll("assets/", "");
    audioPlayer = AudioPlayer();
    audioPlayer.play(AssetSource(soundName));
    audioPlayer.resume();
    // AudioPlayer audioPlayer = AudioPlayer();
    // AudioCache audioCache = AudioCache(fixedPlayer: audioPlayer);
    // await audioCache.play(soundName);
  }


  static AudioPlayer audioPlayer = AudioPlayer();
  // static AudioCache audioCache = AudioCache(fixedPlayer: audioPlayer);
  static const audio = "sounds/number_main.mp3";
  static AudioPlayer audioPlayerMainBg = AudioPlayer();


  static Future<void> playAudioForBg(String s, bool isStart) async {
    Debug.printLog("Preference.shared.getBool(Preference.isMusic)==>>> ${Preference.shared.getBool(Preference.isMusic)}  $s  $isStart");

    bool isMusicEnabled = Preference.shared.getBool(Preference.isMusic) ?? true;

    if (isMusicEnabled) {
      if (isStart) {
        await audioPlayerMainBg.setReleaseMode(ReleaseMode.loop); // Loop the audio
        await audioPlayerMainBg.setSource(AssetSource(audio)); // Play from assets
        await audioPlayerMainBg.resume();
      } else {
        await audioPlayerMainBg.stop();
      }
    } else if (!isStart && !isMusicEnabled) {
      await audioPlayerMainBg.stop();
    }
  }

  // static playAudioForBg() async {
  //   audioPlayer  = await audioCache.loop(audio, mode: PlayerMode.LOW_LATENCY);
  // }


  /*static playSound(String soundName) async {
    AudioPlayer player = AudioPlayer();
    if(player.playing){
      player.stop();
    }
    var duration = await player.setAsset(soundName);
    Debug.printLog("playSound==>>> "+soundName+"  "+duration.toString());
    player.play();
  }

  static Future<void> playSoundTouchNumber(String soundName) async {
    AudioPlayer player = AudioPlayer();
    if(player.playing){
      player.stop();
    }
    var duration = await player.setAsset(soundName);
    Debug.printLog("playSoundTouchNumber==>>> "+soundName+"  "+duration.toString());
    await player.play();
  }*/

  static textToSpeech(String speakText, FlutterTts flutterTts) async {
    if (Platform.isAndroid) {
      await flutterTts.awaitSpeakCompletion(true);
      await flutterTts.setLanguage("en-GB");
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
      await flutterTts.isLanguageAvailable("en-GB");
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.speak(speakText);
    } else {
      await flutterTts.awaitSpeakCompletion(true);
      await flutterTts.setLanguage("en-AU");
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
      await flutterTts.isLanguageAvailable("en-AU");
      await flutterTts.setSpeechRate(0.4);
      await flutterTts.speak(speakText);
    }
  }

  static void requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
    final info = statuses[Permission.storage].toString();
    print(info);
  }

  static List<int> getListOfRandomNumbers(int maxNumbers,int takeNumbersFromList) {
    var list = List.generate(maxNumbers, (index) => index + 1)..shuffle();
    list.take(takeNumbersFromList);
    return list;
  }

  static nonPersonalizedAds()  {
    if(Platform.isIOS) {
      if (Preference.shared.getString(Preference.trackStatus)
          != Constant.trackingStatus) {
        return true;
      } else {
        return false;
      }
    }else {
      return false;
    }
  }

  static launchURLForYouTube() async {
    if (Platform.isIOS) {
      if (await canLaunch(
          'youtube://www.youtube.com/channel/UCwXdFgeE9KYzlDdR7TG9cMw')) {
        await launch(
            'youtube://www.youtube.com/channel/UCwXdFgeE9KYzlDdR7TG9cMw',
            forceSafariVC: false);
      } else {
        if (await canLaunch(
            'https://www.youtube.com/channel/UCwXdFgeE9KYzlDdR7TG9cMw')) {
          await launch(
              'https://www.youtube.com/channel/UCwXdFgeE9KYzlDdR7TG9cMw');
        } else {
          throw 'Could not launch https://www.youtube.com/channel/UCwXdFgeE9KYzlDdR7TG9cMw';
        }
      }
    } else {
      const url = 'https://www.youtube.com/channel/UCwXdFgeE9KYzlDdR7TG9cMw';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  static launchFacebook() async {

    String fallbackUrl = 'https://www.facebook.com/fluttergame';

    try {
        await launch(fallbackUrl, forceSafariVC: false);

    } catch (e) {
      await launch(fallbackUrl, forceSafariVC: false);
    }
  }
}
