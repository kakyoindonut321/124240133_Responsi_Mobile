import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/game_model.dart';

class GameService {
  static const String _baseUrl = 'https://www.freetogame.com/api';

  // GET /games
  Future<List<GameModel>> fetchGames() async {
    final response = await http.get(Uri.parse('$_baseUrl/games'));

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! List) {
        debugPrint('Response /games bukan List: $decoded');
        throw Exception('Format response daftar game tidak valid');
      }

      return decoded.map<GameModel>((item) {
        try {
          return GameModel.fromJson(Map<String, dynamic>.from(item as Map));
        } catch (e) {
          // Log sementara untuk melihat item JSON yang bermasalah
          debugPrint('Parse gagal: $e');
          debugPrint('Item bermasalah: $item');
          rethrow;
        }
      }).toList();
    }

    throw Exception('Gagal memuat daftar game (${response.statusCode})');
  }

  // GET /game?id={id}
  Future<GameModel> fetchGameDetail(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/game?id=$id'));

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        debugPrint('Response /game bukan Map: $decoded');
        throw Exception('Format response detail game tidak valid');
      }

      return GameModel.fromJson(Map<String, dynamic>.from(decoded));
    }

    throw Exception('Gagal memuat detail game (${response.statusCode})');
  }
}
