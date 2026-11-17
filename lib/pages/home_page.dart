import 'package:flutter/material.dart';

import '../services/game_service.dart';
import '../models/game_model.dart';
import 'detail_page.dart';
import '../widget/game_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GameService _service = GameService();
  late Future<List<GameModel>> _futureGames;

  @override
  void initState() {
    super.initState();
    _futureGames = _service.fetchGames();
  }

  void _retry() {
    setState(() {
      _futureGames = _service.fetchGames();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hydra Games!')),
      body: FutureBuilder<List<GameModel>>(
        future: _futureGames,
        builder: (context, snapshot) {
          // 1. Masih loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 8),
                  const Text('Gagal memuat data'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _retry,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }

          // 3. Sukses
          final List<GameModel> games = snapshot.data ?? [];

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final GameModel game = games[index];
              return GameCard(
                game: game,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(gameId: game.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
