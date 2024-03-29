import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../common/index.dart';
import 'index.dart';

class TableHelper {
  TableHelper._internal();
  factory TableHelper() => _instance;
  static final TableHelper _instance = TableHelper._internal();

  static Database? _database;
  //打开DB
  static open() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, kAppDatabaseName);
    LoggerHelper.i('数据库存储路径path:$path');
    try {
      _database = await openDatabase(path);
      LoggerHelper.d('DB open');
    } catch (e) {
      LoggerHelper.e('DBUtil open() Error $e');
    }
  }

  // 记得及时关闭数据库，防止内存泄漏
  static close() async {
    if (_database == null) {
      return;
    }
    await _database!.close();
    LoggerHelper.d('DB close');
  }

  ///sql助手插入 @tableName:表名  @paramters：参数map
  static Future<int> insertByHelper(String tableName, Map<String, Object> paramters) async {
    if (_database == null) {
      await open();
    }
    return await _database!.insert(tableName, paramters);
  }

  ///sql原生插入
  static Future<int> insert(String sql, List paramters) async {
    if (_database == null) {
      await open();
    }
    //调用样例： dbUtil.insert('INSERT INTO Test(name, value) VALUES(?, ?)',['another name', 12345678]);
    return await _database!.rawInsert(sql, paramters);
  }

  static Future<List<Object?>> batchInsert(String table, List paramters) async {
    if (_database == null) {
      await open();
    }
    var batch = _database!.batch();
    for (var element in paramters) {
      batch.insert(table, element.toMap());
    }
    return await batch.commit();
  }

  ///sql原生查找
  static Future<List<Map>> query(String sql) async {
    if (_database == null) {
      await open();
    }
    return await _database!.rawQuery(sql);
  }

  ///sql原生修改
  static Future<int> update(String sql, List paramters) async {
    if (_database == null) {
      await open();
    }
    //样例：dbUtil.update('UPDATE relation SET fuid = ?, type = ? WHERE uid = ?', [1,2,3]);
    return await _database!.rawUpdate(sql, paramters);
  }

  ///sql原生删除
  static Future<int> delete(String sql, List parameters) async {
    if (_database == null) {
      await open();
    }
    //样例： 样例：await dbUtil.delete('DELETE FROM relation WHERE uid = ? and fuid = ?', [123,234]);
    return await _database!.rawDelete(sql, parameters);
  }

  static Future<int> deleteAll(String table) async {
    if (_database == null) {
      await open();
    }
    //样例： 样例：await dbUtil.delete('DELETE FROM relation WHERE uid = ? and fuid = ?', [123,234]);
    return await _database!.delete(table);
  }

  Future init() async {
    await open();
    //所有的sql语句
    Map<String, String> allTableSqls = AppTables.fetchTableCreateSQList();
    //检查需要生成的表
    List<String> noCreateTables = await _getNoCreateTables(allTableSqls);
    LoggerHelper.d('noCreateTables:$noCreateTables');
    if (noCreateTables.isNotEmpty) {
      //创建新表
      // 关闭上面打开的db，否则无法执行open
      await close();
      String databasePath = await getDatabasesPath();
      String path = join(databasePath, kAppDatabaseName);
      _database = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
        LoggerHelper.d('db created version is $version');
      }, onOpen: (Database db) async {
        // ignore: avoid_function_literals_in_foreach_calls
        noCreateTables.forEach((sql) async {
          await db.execute(allTableSqls[sql]!);
        });
        LoggerHelper.d('db补完表已打开');
      });
    } else {
      LoggerHelper.d("表都存在, db已打开");
    }
    List tableMaps = await _database!.rawQuery('SELECT name FROM sqlite_master WHERE type = "table"');
    LoggerHelper.d('所有表:$tableMaps');
    await close();
  }

  /// 检查数据库中是否有所有有表,返回需要创建的表
  Future<List<String>> _getNoCreateTables(Map<String, String> tableSqls) async {
    Iterable<String> tableNames = tableSqls.keys;
    //已经存在的表
    List<String> existingTables = [];
    //要创建的表
    List<String> createTables = [];
    List tableMaps = await _database!.rawQuery('SELECT name FROM sqlite_master WHERE type = "table"');
    for (var item in tableMaps) {
      existingTables.add(item['name']);
    }
    for (var tableName in tableNames) {
      if (!existingTables.contains(tableName)) {
        createTables.add(tableName);
      }
    }
    return createTables;
  }
}
