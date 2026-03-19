import 'package:flutter/services.dart';
import 'package:learn_numbers_flutter/database/tables/colors_pic_table.dart';
import 'package:learn_numbers_flutter/database/tables/colors_pic_table.dart';
import 'package:learn_numbers_flutter/database/tables/colors_pic_table.dart';
import 'package:learn_numbers_flutter/database/tables/count_numbers_table.dart';
import 'package:learn_numbers_flutter/database/tables/game_category_table.dart';
import 'package:learn_numbers_flutter/database/tables/game_category_table.dart';
import 'package:learn_numbers_flutter/database/tables/game_category_table.dart';
import 'package:learn_numbers_flutter/database/tables/learn_numbers_table.dart';
import 'package:learn_numbers_flutter/database/tables/tracing_numbers_table.dart';
import 'package:learn_numbers_flutter/utils/debug.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'dart:io' as io;


class DataBaseHelper {

  String gameCategoryTable = "gamesCategory";
  String learnNumbersTable = "learnNumbersTable";
  String countNumberTable = "countNumberTable";
  String tracingTable = "tracingTable";
  String colorTable = "colorTable";


  static final DataBaseHelper instance = DataBaseHelper.internal();

  factory DataBaseHelper() => instance;

  Database? _db;

  DataBaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await init();
    return _db!;
  }

  init() async {

    var dbPath = await getDatabasesPath();
    Debug.printLog("getDatabasesPathLearnNumbers ===>" + dbPath.toString());

    String dbPathHomeWorkout = path.join(dbPath, "LearnNumbers.db");
    Debug.printLog("dbPathLearnNumbers ===>" + dbPathHomeWorkout.toString());

    bool dbExistsEnliven = await io.File(dbPathHomeWorkout).exists();

    if (!dbExistsEnliven) {
      ByteData data = await rootBundle
          .load(path.join("assets/database", "LearnNumbers.db"));
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await io.File(dbPathHomeWorkout).writeAsBytes(bytes, flush: true);
    }

    return _db = await openDatabase(dbPathHomeWorkout);
  }





  Future<List<GamesCategoryTable>> getAllGamesCategory() async {
    List<GamesCategoryTable> gamesList = [];
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient
        .rawQuery("SELECT * FROM $gameCategoryTable");
    if (maps.isNotEmpty) {
      for (var answer in maps) {
        var gamesData = GamesCategoryTable.fromJson(answer);
        gamesList.add(gamesData);
      }
    }
    return gamesList;
  }



  Future<List<LearnNumbersTable>> getAllLearnNumberData() async {
    List<LearnNumbersTable> learnNumbersDataList = [];
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient
        .rawQuery("SELECT * FROM $learnNumbersTable");
    if (maps.isNotEmpty) {
      for (var answer in maps) {
        var learnNumbersData = LearnNumbersTable.fromJson(answer);
        learnNumbersDataList.add(learnNumbersData);
      }
    }
    return learnNumbersDataList;
  }

  Future<List<CountNumbersTable>> getAllCountNumberData() async {
    List<CountNumbersTable> learnNumbersDataList = [];
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient
        .rawQuery("SELECT * FROM $countNumberTable");
    if (maps.isNotEmpty) {
      for (var answer in maps) {
        var learnNumbersData = CountNumbersTable.fromJson(answer);
        learnNumbersDataList.add(learnNumbersData);
      }
    }
    return learnNumbersDataList;
  }


  Future<List<TracingNumbersTable>> getAllTracingNumbers() async {
    List<TracingNumbersTable> tracingNumbersDataList = [];
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient
        .rawQuery("SELECT * FROM $tracingTable");
    if (maps.isNotEmpty) {
      for (var answer in maps) {
        var tracNumbersData = TracingNumbersTable.fromJson(answer);
        tracingNumbersDataList.add(tracNumbersData);
      }
    }
    return tracingNumbersDataList;
  }

  Future<List<ColorsPicTable>> getAllColorsPic() async {
    List<ColorsPicTable> tracingNumbersDataList = [];
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient
        .rawQuery("SELECT * FROM $colorTable");
    if (maps.isNotEmpty) {
      for (var answer in maps) {
        var tracNumbersData = ColorsPicTable.fromJson(answer);
        tracingNumbersDataList.add(tracNumbersData);
      }
    }
    return tracingNumbersDataList;
  }
}