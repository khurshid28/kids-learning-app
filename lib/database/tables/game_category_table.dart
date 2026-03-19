import 'dart:convert';

class GamesCategoryTable {
  int? id;
  String? gameName;
  String? image;
  String? moveScreen;

  GamesCategoryTable({
    this.id,
    this.gameName,
    this.image,
    this.moveScreen,
});

  factory GamesCategoryTable.fromRawJson(String str) =>
      GamesCategoryTable.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GamesCategoryTable.fromJson(Map<String, dynamic> json) => GamesCategoryTable(
    id: json["id"],
    gameName: json["gameName"],
    image: json["image"],
    moveScreen: json["moveScreen"],

  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "gameName": gameName,
    "image": image,
    "moveScreen": moveScreen,
  };

}