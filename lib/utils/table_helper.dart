import 'package:mizar_music_app/common/app_table.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../common/index.dart';
import 'index.dart';

class TableHelper {
  TableHelper._internal();
  factory TableHelper() => _instance;
  static final TableHelper _instance = TableHelper._internal();

  late Database db;
  //打开DB
  open() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, kAppDatabaseName);
    LoggerHelper.d('数据库存储路径path:$path');
    try {
      db = await openDatabase(path);
      LoggerHelper.d('DB open');
    } catch (e) {
      LoggerHelper.e('DBUtil open() Error $e');
    }
  }

  // 记得及时关闭数据库，防止内存泄漏
  close() async {
    await db.close();
    LoggerHelper.d('DB close');
  }

  ///sql助手插入 @tableName:表名  @paramters：参数map
  Future<int> insertByHelper(String tableName, Map<String, Object> paramters) async {
    return await db.insert(tableName, paramters);
  }

  ///sql原生插入
  Future<int> insert(String sql, List paramters) async {
    //调用样例： dbUtil.insert('INSERT INTO Test(name, value) VALUES(?, ?)',['another name', 12345678]);
    return await db.rawInsert(sql, paramters);
  }

  ///sql原生查找列表
  Future<List<Map>> queryList(String sql) async {
    return await db.rawQuery(sql);
  }

  ///sql原生修改
  Future<int> update(String sql, List paramters) async {
    //样例：dbUtil.update('UPDATE relation SET fuid = ?, type = ? WHERE uid = ?', [1,2,3]);
    return await db.rawUpdate(sql, paramters);
  }

  ///sql原生删除
  Future<int> delete(String sql, List parameters) async {
    //样例： 样例：await dbUtil.delete('DELETE FROM relation WHERE uid = ? and fuid = ?', [123,234]);
    return await db.rawDelete(sql, parameters);
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
      db = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
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
    List tableMaps = await db.rawQuery('SELECT name FROM sqlite_master WHERE type = "table"');
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
    List tableMaps = await db.rawQuery('SELECT name FROM sqlite_master WHERE type = "table"');
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
