import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/game_model.dart';

class LibraryService {
  static const String boxName = 'Library';

  // Mengambil box yang sudah dibuka di main.dart
  Box get _box => Hive.box(boxName);
  // Dipakai LibraryPage untuk auto-refresh saat isi box berubah
  ValueListenable<Box> get listenable => _box.listenable();

  // Semua favorit -> List<GameModel>
  List<GameModel> getLibrary() {
    return _box.values.map((item) => GameModel.fromMap(item as Map)).toList();
  }

  // Cek apakah game ini sudah di library mungkin idk
  bool isLibrary(int id) {
    return _box.containsKey(id);
  }

  // Tambah favorit: key = id show, value = Map
  Future<void> addLibrary(GameModel show) async {
    await _box.put(show.id, show.toMap());
  }

  // Hapus favorit berdasarkan id
  Future<void> removeLibrary(int id) async {
    await _box.delete(id);
  }

  // Kalau sudah favorit -> hapus, kalau belum -> tambah
  // Mengembalikan status terbaru (true = sekarang favorit)
  Future<bool> toggleLibrary(GameModel show) async {
    if (isLibrary(show.id)) {
      await removeLibrary(show.id);
      return false;
    } else {
      await addLibrary(show);
      return true;
    }
  }
}
