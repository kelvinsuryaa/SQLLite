import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqlHelper {
  // Membuka database
  static Future<Database> db() async {
    return openDatabase(
      join(await getDatabasesPath(), 'kindacode.db'),
      version: 2, // Tingkatkan versi database
      onUpgrade: (Database database, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await database.execute("""
            ALTER TABLE items ADD COLUMN price REAL DEFAULT 0
          """);
        }
      },
      onCreate: (Database database, int version) async {
        await database.execute("""
          CREATE TABLE items(
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            title TEXT,
            description TEXT,
            imagePath TEXT,
            price REAL DEFAULT 0,
            createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
          )
        """);
      },
    );
  }

  // Mendapatkan semua data
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SqlHelper.db();
    return db.query('items',
        orderBy: "id DESC"); // Mengurutkan dari yang terbaru
  }

  // Mendapatkan data berdasarkan ID
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SqlHelper.db();
    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Menambahkan data
  static Future<int> createItem(String title, String? description,
      String? imagePath, double price) async {
    final db = await SqlHelper.db();
    final data = {
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'price': price,
    };
    return await db.insert('items', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Memperbarui data berdasarkan ID
  static Future<int> updateItem(int id, String title, String? description,
      String? imagePath, double price) async {
    final db = await SqlHelper.db();
    final data = {
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'price': price,
      'createdAt': DateTime.now().toString(), // Update timestamp
    };
    return await db.update('items', data, where: "id = ?", whereArgs: [id]);
  }

  // Menghapus data berdasarkan ID
  static Future<int> deleteItem(int id) async {
    final db = await SqlHelper.db();
    return await db.delete('items', where: "id = ?", whereArgs: [id]);
  }
}
