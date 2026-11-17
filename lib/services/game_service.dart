import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/game_model.dart';

class TvMazeService {
  static const String _baseUrl = ' https://www.freetogame.com/api';

  // GET /games -> daftar semua show
  Future<List<GameModel>> fetchGames() async {
    final response = await http.get(Uri.parse('$_baseUrl/games'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => GameModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat daftar show (${response.statusCode})');
    }
  }

  // GET /shows/{id} -> detail satu show
  Future<GameModel> fetchShowDetail(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/games?id=$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return GameModel.fromJson(data);
    } else {
      throw Exception('Gagal memuat detail show (${response.statusCode})');
    }
  }
}
