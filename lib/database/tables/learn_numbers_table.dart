import 'dart:convert';
// import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart';

class LearnNumbersTable {
  int? id;
  String? categoryName;
  String? soundName;
  double opacity = 1;
  AudioPlayer? player;
  // AudioCache? audioCache;

  LearnNumbersTable({
    this.id,
    this.categoryName,
    this.soundName,
});

  factory LearnNumbersTable.fromRawJson(String str) =>
      LearnNumbersTable.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LearnNumbersTable.fromJson(Map<String, dynamic> json) => LearnNumbersTable(
    id: json["id"],
    categoryName: json["categoryName"],
    soundName: json["soundName"],

  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "categoryName": categoryName,
    "soundName": soundName,
  };

}