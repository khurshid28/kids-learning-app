import 'dart:convert';

class CountNumbersTable {
  int? id;
  String? imgCount;
  String? imgCountExample;
  String? imgCountBg;
  String? imgName;
  double opacity = 1;

  CountNumbersTable({
    this.id,
    this.imgCount,
    this.imgCountExample,
    this.imgCountBg,
    this.imgName,
});

  factory CountNumbersTable.fromRawJson(String str) =>
      CountNumbersTable.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CountNumbersTable.fromJson(Map<String, dynamic> json) => CountNumbersTable(
    id: json["id"],
    imgCount: json["imgCount"],
    imgCountExample: json["imgCountExample"],
    imgCountBg: json["imgCountBg"],
    imgName: json["imgName"],

  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "imgCount": imgCount,
    "imgCountExample": imgCountExample,
    "imgCountBg": imgCountBg,
    "imgName": imgName,

  };

}