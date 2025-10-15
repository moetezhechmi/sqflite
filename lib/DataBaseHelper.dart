import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'notes.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE note (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)',
        );
      },
    );
  }

  Future<int> insertNote(String name) async {
    final mydb = await db;
    return await mydb.insert('note', {'name': name});
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    final mydb = await db;
    return await mydb.query('note', orderBy: 'id DESC');
  }

  Future<int> deleteNote(int id) async {
    final mydb = await db;
    return await mydb.delete('note', where: 'id = ?', whereArgs: [id]);
  }
}
