import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbProvider {
  static final _dbName = 'mytasks.db';
  static final _dbVersion = 1;
  static final _tableName = 'tasks';

  //making it a singleton class (only one instance through out the app)
  DbProvider._privateConstructor();
  static final DbProvider instance = DbProvider._privateConstructor();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    print('excute create table');
    await db.execute('''
        CREATE TABLE $_tableName(
        _id INTEGER PRIMARY KEY,
        task TEXT NOT NULL,
        date TEXT ,
        status TEXT NOT NULL )        
        ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(_tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await instance.database;
    return await db.query(_tableName);
  }

  Future query(Map<String, dynamic> row) async {
    Database db = await instance.database;
    String status = row['status'];
    return await db.query(_tableName, where: 'status = ?', whereArgs: [status]);
  }

  Future update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['_id'];
    String status = row['status'];
    return await db.update(_tableName, row, where: '_id = ?', whereArgs: [id]);
  }

  Future delete(int id) async {
    Database db = await instance.database;
    return await db.delete(_tableName, where: '_id = ?', whereArgs: [id]);
  }
}
