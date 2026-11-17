import 'package:flutter/material.dart';

import '../models/game_model.dart';
import '../services/library_service.dart';
import '../services/game_service.dart';

class DetailPage extends StatefulWidget {
  final int gameId;

  const DetailPage({super.key, required this.gameId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final GameService _service = GameService();
  final LibraryService _favorites = LibraryService();
  late Future<GameModel> _futureGame;

  @override
  void initState() {
    super.initState();
    _futureGame = _service.fetchGameDetail(widget.gameId);
  }

  void _retry() {
    setState(() {
      _futureGame = _service.fetchGameDetail(widget.gameId);
    });
  }

  Future<void> _toggleLibrary(GameModel game) async {
    final bool nowFavorite = await _favorites.toggleLibrary(game);

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nowFavorite
              ? '${game.title} ditambahkan ke favorit'
              : '${game.title} dihapus dari favorit',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: FutureBuilder<GameModel>(
        future: _futureGame,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 8),
                  const Text('Gagal memuat detail'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _retry,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }

          final GameModel game = snapshot.data!;
          final bool isFavorite = _favorites.isLibrary(game.id);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar
                if (game.thumbnail != null)
                  Image.network(
                    game.thumbnail!,
                    width: double.infinity,
                    height: 400,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(
                          height: 400,
                          child: Center(child: Icon(Icons.movie, size: 64)),
                        ),
                  )
                else
                  const SizedBox(
                    height: 400,
                    child: Center(child: Icon(Icons.movie, size: 64)),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul
                      Text(
                        game.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.star, size: 18, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(game.genre),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Genre
                      // Text(
                      //   game.genres.isEmpty ? '-' : game.genres.join(', '),
                      //   style: const TextStyle(color: Colors.grey),
                      // ),
                      const SizedBox(height: 16),

                      // Tombol favorit
                      ElevatedButton.icon(
                        onPressed: () => _toggleLibrary(game),
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                        ),
                        label: Text(
                          isFavorite
                              ? 'Hapus dari Favorit'
                              : 'Tambah ke Favorit',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(46),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Summary
                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        game.description.isEmpty
                            ? 'Tidak ada ringkasan.'
                            : game.description,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
