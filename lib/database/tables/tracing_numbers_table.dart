import 'dart:convert';


class TracingNumbersTable {
  int? id;
  String? categoryName;
  String? imgName;


  TracingNumbersTable({
    this.id,
    this.categoryName,
    this.imgName,
});

  factory TracingNumbersTable.fromRawJson(String str) =>
      TracingNumbersTable.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TracingNumbersTable.fromJson(Map<String, dynamic> json) => TracingNumbersTable(
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