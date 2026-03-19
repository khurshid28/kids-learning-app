import 'dart:convert';

import 'package:flutter/material.dart';


class ColorsPicTable {
  int? id;
  String? categoryName;
  String? imgName;
  GlobalKey? previewContainer;


  ColorsPicTable({
    this.id,
    this.categoryName,
    this.imgName,
});

  factory ColorsPicTable.fromRawJson(String str) =>
      ColorsPicTable.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ColorsPicTable.fromJson(Map<String, dynamic> json) => ColorsPicTable(
    id: json["id"],
    categoryName: json["categoryName"],
    imgName: json["imgName"],

  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "categoryName": categoryName,
    "imgName": imgName,
  };

}